package com.thefuntasty.flowlist.adapter;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.fragment.CalendarFragment;
import com.thefuntasty.flowlist.model.FlowDay;
import com.thefuntasty.flowlist.tool.DateUtil;
import com.thefuntasty.flowlist.view.CalendarListViewItemDay;
import com.thefuntasty.flowlist.view.PinnedSectionListView;

import java.util.ArrayList;
import java.util.Calendar;

public class CalendarListAdapter extends BaseAdapter implements PinnedSectionListView.PinnedSectionListAdapter {

	private static final int DAYS_IN_WEEK = 7;
	private static final String TAG = CalendarListAdapter.class.getSimpleName();

	private final LayoutInflater mLayoutInflater;
	private final Calendar mCalendar;
	private final View.OnClickListener mListener;
	private ArrayList<CalendarFragment.CalendarRow> mData;

	public CalendarListAdapter(Context context, ArrayList<CalendarFragment.CalendarRow> data,
							   @Nullable View.OnClickListener listener) {
		mData = (data == null) ? new ArrayList<CalendarFragment.CalendarRow>() : data;
		mLayoutInflater = LayoutInflater.from(context);
		mCalendar = DateUtil.getCal();
		mListener = listener;
	}

	public void setData(ArrayList<CalendarFragment.CalendarRow> data) {
		mData = (data == null) ? new ArrayList<CalendarFragment.CalendarRow>() : data;
		notifyDataSetChanged();
	}

	@Override
	public int getCount() {
		return mData.size();
	}

	@Override
	public Object getItem(int i) {
		return mData.get(i);
	}

	@Override
	public long getItemId(int i) {
		return i;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		CalendarFragment.CalendarRow parentRow = (CalendarFragment.CalendarRow) getItem(position);

		if (convertView == null) {
			if (parentRow.isSection()) {
				convertView = mLayoutInflater.inflate(R.layout.calendar_list_view_item_section, parent, false);
			} else {
				convertView = mLayoutInflater.inflate(R.layout.calendar_list_view_item_week, parent, false);
			}
		}

		if (parentRow.isSection()) {
			CalendarFragment.CalendarSectionRow row = (CalendarFragment.CalendarSectionRow) parentRow;

			((TextView) convertView).setText(DateUtil.getSectionName(row.mDate));
		} else {
			CalendarFragment.CalendarWeekRow row = (CalendarFragment.CalendarWeekRow) parentRow;
			LinearLayout container = (LinearLayout) convertView;

			if (container.getChildCount() != DAYS_IN_WEEK) {
				for (int i = 0; i < DAYS_IN_WEEK; i++) {
					container.addView(new CalendarListViewItemDay(mLayoutInflater.getContext()));
				}
			}

			mCalendar.setTime(row.mFirstDay.getTime());
			int dayOffset = row.mDaysOffset;
			int validDaysCount = row.mValidDaysInWeek;

			for (int i = 0; i < DAYS_IN_WEEK; i++) {
				CalendarListViewItemDay childView = (CalendarListViewItemDay) container.getChildAt(i);
				childView.setDayText(DateUtil.getDayInWeek(mCalendar.getTime()));
				childView.setDayNumber(DateUtil.getDateString(mCalendar.getTime()));
				childView.setTag(mCalendar.getTimeInMillis());

				FlowDay flowDay = App.getStore().getDay(mCalendar.getTimeInMillis());
				if (mCalendar.get(Calendar.MONTH) != row.mActualMonth) { // outside current month
					childView.setInactive();
					childView.setOnClickListener(null);

				} else if (i < dayOffset) { // first week unselectable days
					childView.setInactive();
					childView.setOnClickListener(null);

				} else if (i >= dayOffset && (dayOffset + validDaysCount) <= i) { //last week unselectable days
					childView.setInactive();
					childView.setOnClickListener(null);

				} else if (flowDay == null || flowDay.skipped) { // flow day not filled
					childView.setAvailable();
					childView.setOnClickListener(mListener);

				} else if (i >= dayOffset && (dayOffset + validDaysCount) >= i) { // valid days
					childView.setOnClickListener(mListener);
					if (flowDay.isStarred()) {
						childView.setStarred();
					} else {
						childView.setFilled();
					}

				} else {
					Log.e(TAG, "Something goes wrong: " + String.valueOf(i) + mCalendar.get(Calendar.MONTH));
				}

				mCalendar.add(Calendar.DAY_OF_YEAR, 1);
			}
		}

		return convertView;
	}

	@Override
	public int getItemViewType(int position) {
		if (mData == null || mData.isEmpty() || position < 0) return 0;
		else return mData.get(position).isSection() ? 1 : 0;
	}

	@Override
	public int getViewTypeCount() {
		return 2;
	}

	@Override
	public boolean isItemViewTypePinned(int viewType) {
		return viewType == 1;
	}
}
