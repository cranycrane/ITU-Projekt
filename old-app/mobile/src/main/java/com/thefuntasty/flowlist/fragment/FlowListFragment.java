package com.thefuntasty.flowlist.fragment;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.pnikosis.materialishprogress.ProgressWheel;
import com.squareup.otto.Subscribe;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.activity.FillMissingActivity;
import com.thefuntasty.flowlist.adapter.FlowListPagerAdapter;
import com.thefuntasty.flowlist.event.FlowListPagesUpdateEvent;
import com.thefuntasty.flowlist.event.SyncInProgressEvent;
import com.thefuntasty.flowlist.slidingtab.SlidingTabLayout;
import com.thefuntasty.flowlist.tool.DateUtil;
import com.thefuntasty.flowlist.tool.FlowGoogleAnalytics;
import com.thefuntasty.taste.res.TRes;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.Unbinder;

public class FlowListFragment extends Fragment {
	public static final String DATE_EXTRA = "defaultDate";
	public static final String FIRST_MILLIS_EXTRA = "firstMillis";
	public static final String LAST_MILLIS_EXTRA = "lastMillis";
	private static final String SCREEN_NAME = TRes.string(R.string.screen_flow_list);
	private static final int PAGES_TO_LOAD = 14; // number of pages loaded
	private static final int PAGE_LIMIT_TO_LOAD = 8; // load new pages when ve reach page lower than this number
	public int defaultPage = 0;  // defaultPage - might change, if we put fragments to left positions in viewpager
	@BindView(R.id.fragment_flow_list_sliding_tab)
	SlidingTabLayout mSlidingTabLayout;
	@BindView(R.id.fragment_flow_list_pager)
	ViewPager mPager;
	@BindView(R.id.progress)
	ProgressWheel mProgress;
	@BindView(R.id.parent)
	LinearLayout mParent;
	private Unbinder unbinder;

	private long mDefaultDate = 0;
	private long mFirstMillis = 0;
	private long mLastMillis = 0;
	private FlowListPagerAdapter mAdapter;
	private int mCurrentPage = 0;
	private final ViewPager.SimpleOnPageChangeListener pageL = new ViewPager.SimpleOnPageChangeListener() {

		boolean pageSelected = false;
		private int mState = -1;

		@Override
		public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

			// figure out if we really scrolled to *new* position
			if (pageSelected &&
					(mState == ViewPager.SCROLL_STATE_SETTLING || mState == ViewPager.SCROLL_STATE_IDLE)) {

				mCurrentPage = position;
				pageSelected = false;

				final FlowListPagerAdapter adapter = (FlowListPagerAdapter) mPager.getAdapter();

				if (mCurrentPage >= 0 && mCurrentPage < PAGE_LIMIT_TO_LOAD && !mAdapter.mLeftLimitReached) {
					int addedFragmentsCount = 0;
					int limit = PAGES_TO_LOAD - mCurrentPage; // number of pages loaded depends on page we're at
					for (int i = 0; i < limit; i++) {
						addedFragmentsCount += adapter.addFragmentLeft(); // mCurrentPage == 0 -> we must not look for data at pos + 1
					}
					mPager.getAdapter().notifyDataSetChanged();
					adapter.moveToRight(addedFragmentsCount); // rotate right
				}

				int offset = mPager.getAdapter().getCount() - mCurrentPage;

				if (offset > 0 && offset <= PAGE_LIMIT_TO_LOAD && !mAdapter.mRightLimitReached) {
					int limit = PAGES_TO_LOAD - offset; // number of pages loaded depends on page we're at
					for (int i = 0; i < limit; i++) {
						adapter.addFragmentRight();
					}
					mPager.getAdapter().notifyDataSetChanged();
				}
			}
		}

		@Override
		public void onPageSelected(int position) {
			mCurrentPage = position;
			pageSelected = true; // page has been selected
		}

		@Override
		public void onPageScrollStateChanged(int state) {
			mState = state;
		}
	};

	@Subscribe
	public void refresh(FlowListPagesUpdateEvent e) {
		if (e.mRecreateAll) {
			defaultPage = 0;
			mCurrentPage = 0;
			mAdapter = new FlowListPagerAdapter(FlowListFragment.this.getChildFragmentManager(), mPager, mSlidingTabLayout, this);
			mPager.setAdapter(mAdapter);
			initAdapter();
		} else {
			mPager.getAdapter().notifyDataSetChanged();
		}
	}

	@Subscribe
	public void loading(SyncInProgressEvent event) {
		if (event.mPullToRefresh) {
			return;
		}

		if (event.mIsRunning) {
			mProgress.setVisibility(View.VISIBLE);
			mParent.setVisibility(View.GONE);
		} else {
			mProgress.setVisibility(View.GONE);
			mParent.setVisibility(View.VISIBLE);
		}
	}

	private void initAdapter() {
		for (int i = 0; i < 15; i++) { // load some content at startup
			mAdapter.addFragmentRight();
		}

		int addedFragmentsLeft = 0;
		for (int i = 0; i < 15; i++) { // load some content at startup
			addedFragmentsLeft += mAdapter.addFragmentLeft();
		}

		mPager.getAdapter().notifyDataSetChanged();
		mAdapter.moveToRight(addedFragmentsLeft);
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == FillMissingActivity.FILL_MISSING_REQUEST) {
			if (resultCode == Activity.RESULT_OK) {
				App.getStore().setDefaultDataPos(mDefaultDate);
				refresh(new FlowListPagesUpdateEvent(true));
			}
		}
	}

	@Override
	public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
		View view = inflater.inflate(R.layout.fragment_flow_list, container, false);
		unbinder = ButterKnife.bind(this, view);
		FlowGoogleAnalytics.screen(SCREEN_NAME);
		setHasOptionsMenu(true);
		return view;
	}

	@Override
	public void onActivityCreated(@Nullable Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);

		if (getArguments() != null) {
			mDefaultDate = getArguments().getLong(DATE_EXTRA, DateUtil.getCal().getTimeInMillis());
			mFirstMillis = getArguments().getLong(FIRST_MILLIS_EXTRA, 0);
			mLastMillis = getArguments().getLong(LAST_MILLIS_EXTRA, 0);
		}

		mAdapter = new FlowListPagerAdapter(this.getChildFragmentManager(), mPager, mSlidingTabLayout, this);
		mPager.setOffscreenPageLimit(1);
		mPager.setAdapter(mAdapter);
		mSlidingTabLayout.setCustomTabView(R.layout.flow_list_bar_item, R.id.flow_list_bar_item_text);
		mSlidingTabLayout.setViewPager(mPager);
		mSlidingTabLayout.setOnPageChangeListener(pageL);

		App.getStore().setDefaultDataPos(mDefaultDate, mFirstMillis, mLastMillis);
		defaultPage = 0;
		mCurrentPage = 0;
		initAdapter();
	}

	@Override
	public void onStart() {
		super.onStart();
		App.bus().register(this);
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
}
