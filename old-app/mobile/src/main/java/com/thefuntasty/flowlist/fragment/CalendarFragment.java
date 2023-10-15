package com.thefuntasty.flowlist.fragment;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.LoaderManager;
import android.support.v4.content.Loader;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.adapter.CalendarListAdapter;
import com.thefuntasty.flowlist.event.ChangeFragmentEvent;
import com.thefuntasty.flowlist.task.CalendarListLoadTask;
import com.thefuntasty.flowlist.tool.FlowGoogleAnalytics;
import com.thefuntasty.taste.res.TRes;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

public class CalendarFragment extends Fragment implements LoaderManager.LoaderCallbacks<ArrayList<CalendarFragment.CalendarRow>> {
	private static final String SCREEN_NAME = TRes.string(R.string.screen_calendar);
	private final View.OnClickListener mDayClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View view) {
			long millis = (Long) view.getTag();
			App.mDrawerPosition = 0;
			App.bus().post(new ChangeFragmentEvent(0, millis));
		}
	};
	private ListView mListView;
	private CalendarListAdapter mAdapter;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setHasOptionsMenu(true);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
		View v = inflater.inflate(R.layout.fragment_calendar, container, false);
		mListView = (ListView) v.findViewById(R.id.calendar_fragment_listview);

		FlowGoogleAnalytics.screen(SCREEN_NAME);
		return v;
	}

	@Override
	public void onActivityCreated(@Nullable Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
		mAdapter = new CalendarListAdapter(getActivity(), null, mDayClickListener);
		mListView.setAdapter(mAdapter);
		getLoaderManager().initLoader(0, null, CalendarFragment.this);
	}

	@Override
	public Loader<ArrayList<CalendarRow>> onCreateLoader(int id, Bundle args) {
		return new CalendarListLoadTask(getActivity());
	}

	@Override
	public void onLoadFinished(Loader<ArrayList<CalendarRow>> arrayListLoader, ArrayList<CalendarRow> calendarRows) {
		mAdapter.setData(calendarRows);
	}

	@Override
	public void onLoaderReset(Loader<ArrayList<CalendarRow>> loader) {
		mAdapter.setData(null);
	}

	public interface CalendarRow {
		boolean isSection();
	}

	public static class CalendarWeekRow implements CalendarRow {

		public final Calendar mFirstDay;
		public final int mActualMonth;
		public final int mValidDaysInWeek;
		public final int mDaysOffset;

		public CalendarWeekRow(Calendar firstDay, int month, int validDays, int daysOffset) {
			mFirstDay = firstDay;
			mActualMonth = month;
			mValidDaysInWeek = validDays;
			mDaysOffset = daysOffset;
		}

		@Override
		public boolean isSection() {
			return false;
		}
	}

	public static class CalendarSectionRow implements CalendarRow {

		public Date mDate;

		public CalendarSectionRow(Date date) {
			mDate = date;
		}

		@Override
		public boolean isSection() {
			return true;
		}
	}
}
