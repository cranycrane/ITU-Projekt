package com.thefuntasty.flowlist.fragment;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.ScaleAnimation;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.squareup.otto.Subscribe;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.activity.FillMissingActivity;
import com.thefuntasty.flowlist.activity.NumberPickerActivity;
import com.thefuntasty.flowlist.activity.OneRecordActivity;
import com.thefuntasty.flowlist.event.SyncInProgressEvent;
import com.thefuntasty.flowlist.model.FlowDay;
import com.thefuntasty.flowlist.model.FlowListItem;
import com.thefuntasty.flowlist.model.FlowListItem.FlowListDay;
import com.thefuntasty.flowlist.tool.DateUtil;
import com.thefuntasty.flowlist.tool.Util;
import com.thefuntasty.flowlist.view.SourceSansProLightTextView;
import com.thefuntasty.taste.res.TRes;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.Unbinder;

public class FlowListItemFragment extends Fragment implements View.OnClickListener, SwipeRefreshLayout.OnRefreshListener {

	public static final int RECORD_REQUEST = 333;
	public static final int SCORE_REQUEST = 444;
	public static final int RECORD_1_TAG = 1;
	public static final int RECORD_2_TAG = 2;
	public static final int RECORD_3_TAG = 3;

	@BindView(R.id.flow_list_score)
	TextView mScore;
	@BindView(R.id.flow_list_item_empty_text)
	TextView mEmptyIntervalText;
	@BindView(R.id.flow_list_records_cont)
	LinearLayout mRecordsCont;
	@BindView(R.id.flow_list_no_records)
	TextView mNoRecordsText;
	@BindView(R.id.score_bg)
	View mScoreBg;
	@BindView(R.id.score_plus)
	View mScorePlus;
	@BindView(R.id.score_cont)
	FrameLayout mScoreCont;
	@BindView(R.id.refresh)
	SwipeRefreshLayout mRefresh;
	@BindView(R.id.refresh_empty)
	SwipeRefreshLayout mRefreshEmpty;
	boolean hasBeenAnimated = false;
	ScaleAnimation mScaleAnim;
	AlphaAnimation mAlphaAnim;
	private FlowListItem mData;
	private RelativeLayout mDayLayout;
	private LinearLayout mEmptyIntervalLayout;
	private int mPosition;
	private Unbinder unbinder;

	@Override
	public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
		FrameLayout view = (FrameLayout) inflater.inflate(R.layout.flow_list_item, container, false);

		mDayLayout = (RelativeLayout) view.findViewById(R.id.item_day);
		mEmptyIntervalLayout = (LinearLayout) view.findViewById(R.id.item_interval_empty);

		view.setClipChildren(false);
		view.setClipToPadding(false);

		unbinder = ButterKnife.bind(this, view);
		return view;
	}

	@Override
	public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
		super.onViewCreated(view, savedInstanceState);

		mRefresh.setColorSchemeColors(TRes.color(R.color.main_red));
		mRefresh.setOnRefreshListener(this);

		mRefreshEmpty.setColorSchemeColors(TRes.color(R.color.main_red));
		mRefreshEmpty.setOnRefreshListener(this);

		FrameLayout frameLayout = (FrameLayout) view;
		if (frameLayout != null) {
			frameLayout.setClipChildren(false);
			frameLayout.setClipToPadding(false);
		}
	}

	@Override
	public void onActivityCreated(@Nullable Bundle bundle) {
		super.onActivityCreated(bundle);
		setHasOptionsMenu(true);
	}

	@Override
	public void onStart() {
		super.onStart();
		App.bus().register(this);
	}

	@Override
	public void onResume() {
		super.onResume();
		parseData();

		if (hasBeenAnimated) {
			reverseAnimation();
			hasBeenAnimated = false;
		} else {
			((AppCompatActivity) getActivity()).getSupportActionBar().show();
		}
	}

	@Override
	public void onStop() {
		super.onStop();
		App.bus().unregister(this);
	}

	@Override
	public void onDestroyView() {
		super.onDestroyView();
		unbinder.unbind();
	}

	@Override
	public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
		super.onCreateOptionsMenu(menu, inflater);
		inflater.inflate(R.menu.flow_list_day_menu, menu);
	}

	@Override
	public void onPrepareOptionsMenu(Menu menu) {
		if (mRecordsCont.getChildCount() != 3 && mData != null && mData.isFlowDay() && !App.mDrawerVisible) {
			menu.findItem(R.id.menu_item_add).setVisible(true);
		} else {
			menu.findItem(R.id.menu_item_add).setVisible(false);
		}
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == R.id.menu_item_add) {
			startActivityGetRecord();
			return true;
		} else {
			return super.onOptionsItemSelected(item);
		}
	}

	@Subscribe
	public void loading(SyncInProgressEvent event) {
		if (event.mPullToRefresh) {
			mRefresh.setRefreshing(event.mIsRunning);
			mRefreshEmpty.setRefreshing(event.mIsRunning);
		}
	}

	@OnClick(R.id.flow_list_item_interval_empty_button)
	public void onEmptyIntervalButtonClick() {
		FlowListItem.FlowListInterval interval = ((FlowListItem.FlowListInterval) mData);

		Bundle bundle = new Bundle();
		bundle.putLong(FlowListFragment.DATE_EXTRA, interval.mLastDay.getTime());
		bundle.putLong(FlowListFragment.FIRST_MILLIS_EXTRA, interval.mFirstDay.getTime());
		bundle.putLong(FlowListFragment.LAST_MILLIS_EXTRA, interval.mLastDay.getTime());

		Intent intent = new Intent(getActivity(), FillMissingActivity.class);
		intent.putExtras(bundle);
		getParentFragment().startActivityForResult(intent, FillMissingActivity.FILL_MISSING_REQUEST);
	}

	private void startActivityGetRecord() {
		Bundle bundle = new Bundle();
		bundle.putInt(OneRecordActivity.RECORD_ID_EXTRA, getFirstEmptyRecordPos()); // childCount() - 1 (records) + 1 (count from 1)
		bundle.putLong(OneRecordActivity.DATE_EXTRA, ((FlowListItem.FlowListDay) mData).mMillis);

		Intent intent = new Intent(getActivity(), OneRecordActivity.class);
		intent.putExtras(bundle);
		getParentFragment().startActivityForResult(intent, RECORD_REQUEST);
	}

	private int getFirstEmptyRecordPos() {
		FlowDay day = ((FlowListItem.FlowListDay) mData).mDay;
		if (TextUtils.isEmpty(day.record1)) {
			return RECORD_1_TAG;
		} else if (TextUtils.isEmpty(day.record2)) {
			return RECORD_2_TAG;
		} else if (TextUtils.isEmpty(day.record3)) {
			return RECORD_3_TAG;
		}
		return -1;
	}

	public TextView addRecord(int tag) {
		LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
		int padding = Util.dpToPx(TRes.resources(), TRes.dimen(R.dimen.p2_5));

		TextView view = new SourceSansProLightTextView(getActivity());
		view.setLayoutParams(params);
		view.setGravity(Gravity.CENTER_VERTICAL);
		view.setTag(tag);
		view.setBackgroundResource(R.drawable.bg_record);
		view.setPadding(padding, padding, padding, padding);
		view.setClickable(true);
		view.setOnClickListener(this);
		view.setTextSize(TypedValue.COMPLEX_UNIT_PX, TRes.pixel(R.dimen.s25));

		mRecordsCont.addView(view, mRecordsCont.getChildCount());
		return view;
	}

	public int getPosition() {
		return mPosition;
	}

	public void setPosition(int position) {
		mPosition = position;
	}

	public void setData(FlowListItem data) {
		mData = data;
		if (isAdded() && data != null) {
			parseData();
		}
	}

	private void parseData() {
		if (mData instanceof FlowListItem.FlowListDay) {
			if (((FlowListDay) mData).mDay == null || ((FlowListDay) mData).mDay.getId() == null) {
				((FlowListDay) mData).mDay = App.getStore().getDay(((FlowListDay) mData).mMillis);
				if (((FlowListDay) mData).mDay == null) {
					((FlowListDay) mData).mDay = new FlowDay(((FlowListDay) mData).mMillis);
				}
			}

			while (mRecordsCont.getChildCount() != 0) {
				mRecordsCont.removeViewAt(0);
			}

			FlowDay day = ((FlowListDay) mData).mDay;
			setDayLayout();
			if (day.isEmpty()) {
				mNoRecordsText.setVisibility(View.VISIBLE);
				mRecordsCont.setVisibility(View.GONE);
			} else {
				mNoRecordsText.setVisibility(View.GONE);
				mRecordsCont.setVisibility(View.VISIBLE);
			}

			tryAddRecord(day.record1, RECORD_1_TAG, day.star1);
			tryAddRecord(day.record2, RECORD_2_TAG, day.star2);
			tryAddRecord(day.record3, RECORD_3_TAG, day.star3);

			setScore(day.score);

		} else if (mData instanceof FlowListItem.FlowListInterval) {
			setEmptyIntervalLayout();
			String first = "";
			String second = "";

			if (((FlowListItem.FlowListInterval) mData).mFirstDay != null) {
				first = DateUtil.dateToStandalone(((FlowListItem.FlowListInterval) mData).mFirstDay);
			}

			if (((FlowListItem.FlowListInterval) mData).mLastDay != null) {
				second = DateUtil.dateToStandalone(((FlowListItem.FlowListInterval) mData).mLastDay);
			}

			mEmptyIntervalText.setText(TRes.string(R.string.fragment_flow_list_interval_text, first, second));
		}
		getActivity().supportInvalidateOptionsMenu();
	}

	private void tryAddRecord(String text, int tag, boolean isStarred) {
		if (!TextUtils.isEmpty(text)) {
			TextView record = addRecord(tag);
			if (isStarred) {
				record.setTextColor(TRes.color(R.color.main_red));
			} else {
				record.setTextColor(TRes.color(R.color.light_gray));
			}
			record.setText(text);
		}
	}

	private void setDayLayout() {
		mDayLayout.setVisibility(View.VISIBLE);
		mEmptyIntervalLayout.setVisibility(View.GONE);
		mRefreshEmpty.setEnabled(false);
		mRefresh.setEnabled(true);
	}

	private void setEmptyIntervalLayout() {
		mDayLayout.setVisibility(View.GONE);
		mEmptyIntervalLayout.setVisibility(View.VISIBLE);
		mRefreshEmpty.setEnabled(true);
		mRefresh.setEnabled(false);
	}

	private void setScore(Integer score) {
		if (score == null) {
			if (mRecordsCont.getChildCount() > 0) {
				mScoreCont.setVisibility(View.VISIBLE);
				mScorePlus.setVisibility(View.VISIBLE);
				mScore.setVisibility(View.GONE);
			} else {
				mScoreCont.setVisibility(View.GONE);
			}
		} else {
			mScoreCont.setVisibility(View.VISIBLE);
			mScorePlus.setVisibility(View.GONE);
			mScore.setVisibility(View.VISIBLE);
			mScore.setText(String.valueOf(score));
		}
	}

	private void reverseAnimation() {
		if (mScaleAnim != null && mAlphaAnim != null) {
			mScaleAnim.setInterpolator(Util.getReverseInterpolator());
			mScaleAnim.setAnimationListener(new Animation.AnimationListener() {
				@Override
				public void onAnimationStart(Animation animation) {

				}

				@Override
				public void onAnimationEnd(Animation animation) {
					((AppCompatActivity) getActivity()).getSupportActionBar().show();
					mScore.setEnabled(true);
				}

				@Override
				public void onAnimationRepeat(Animation animation) {

				}
			});
			mAlphaAnim.setInterpolator(Util.getReverseInterpolator());

			mScore.startAnimation(mAlphaAnim);
			mScoreBg.startAnimation(mScaleAnim);
		}
	}

	@OnClick(R.id.score_cont)
	public void onScoreClick() {
		mAlphaAnim = new AlphaAnimation(1.0f, 0.0f);
		mAlphaAnim.setDuration(500);
		mAlphaAnim.setZAdjustment(Animation.ZORDER_TOP);
		mAlphaAnim.setFillAfter(true);


		mScaleAnim = new ScaleAnimation(1.0f, 20.0f, 1.0f, 20f, Animation.RELATIVE_TO_SELF, 0.8f, Animation.RELATIVE_TO_SELF, 0.7f);
		mScaleAnim.setDuration(600);
		mScaleAnim.setFillAfter(true);
		mScaleAnim.setAnimationListener(new Animation.AnimationListener() {
			@Override
			public void onAnimationStart(Animation animation) {
				mScore.setEnabled(false);
				((AppCompatActivity) getActivity()).getSupportActionBar().hide();
			}

			@Override
			public void onAnimationEnd(Animation animation) {
				Bundle bundle = new Bundle();
				bundle.putLong(NumberPickerActivity.DATE_EXTRA, ((FlowListItem.FlowListDay) mData).mMillis);

				Intent intent = new Intent(getActivity(), NumberPickerActivity.class);
				intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
				intent.putExtras(bundle);
				getParentFragment().startActivityForResult(intent, SCORE_REQUEST);
			}

			@Override
			public void onAnimationRepeat(Animation animation) {

			}
		});
		mScore.startAnimation(mAlphaAnim);
		mScoreBg.startAnimation(mScaleAnim);
		hasBeenAnimated = true;
	}

	@Override
	public void onClick(View v) {
		Integer tag = (Integer) v.getTag();
		if (tag != null) {
			Bundle bundle = new Bundle();
			bundle.putInt(OneRecordActivity.RECORD_ID_EXTRA, tag);
			bundle.putLong(OneRecordActivity.DATE_EXTRA, ((FlowListItem.FlowListDay) mData).mMillis);

			Intent intent = new Intent(getActivity(), OneRecordActivity.class);
			intent.putExtras(bundle);
			getParentFragment().startActivityForResult(intent, RECORD_REQUEST);
		}
	}

	@Override
	public void onRefresh() {
		App.getStore().sync(false, true);
	}
}
