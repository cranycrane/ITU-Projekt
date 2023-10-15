package com.thefuntasty.flowlist.task;


import android.content.Context;
import android.support.v4.content.AsyncTaskLoader;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.fragment.CalendarFragment;
import com.thefuntasty.flowlist.fragment.CalendarFragment.CalendarRow;
import com.thefuntasty.flowlist.fragment.CalendarFragment.CalendarSectionRow;
import com.thefuntasty.flowlist.fragment.CalendarFragment.CalendarWeekRow;
import com.thefuntasty.flowlist.tool.DateUtil;

import java.util.ArrayList;
import java.util.Calendar;

public class CalendarListLoadTask extends AsyncTaskLoader<ArrayList<CalendarFragment.CalendarRow>> {

	private ArrayList<CalendarRow> mList;

	public CalendarListLoadTask(Context context) {
		super(context);
	}

	/**
	 * Transform:
	 * SU, MO, TU, WE, TH, FR, SA -> MO, TU, WE, TH, FR, SA, SU
	 * 1,  2,  3,  4,  5,  6,  7 ->  0,  1,  2,  3,  4,  5,  6
	 *
	 * @param day id of day
	 * @return transformed day id
	 */
	private static int transformDay(int day) {
		return (day + 5) % 7;
	}

	private void moveToPrevMonday(Calendar calendar) {
		if (calendar.get(Calendar.DAY_OF_WEEK) != Calendar.MONDAY) { // aren't today monday?
			int weekday = transformDay(calendar.get(Calendar.DAY_OF_WEEK));
			calendar.add(Calendar.DAY_OF_YEAR, -weekday);
		}
	}

	public int getDayOfWeek(Calendar cal) {
		return transformDay(cal.get(Calendar.DAY_OF_WEEK));
	}

	@Override
	public ArrayList<CalendarRow> loadInBackground() {
		mList = new ArrayList<>();

		Calendar lastDay = DateUtil.getCal();
		lastDay.set(Calendar.HOUR_OF_DAY, 0);
		lastDay.set(Calendar.MINUTE, 0);
		lastDay.set(Calendar.SECOND, 0);
		lastDay.set(Calendar.MILLISECOND, 0);

		Calendar firstWeekDay = (Calendar) lastDay.clone();
		moveToPrevMonday(firstWeekDay);

		Calendar lastWeekDay = (Calendar) firstWeekDay.clone();
		lastWeekDay.add(Calendar.DAY_OF_YEAR, 6); // move to sunday

		int actualMonth = lastDay.get(Calendar.MONTH);

		Calendar firstDay = App.getStore().getFirstDayCal();

		mList.add(new CalendarSectionRow(lastDay.getTime()));
		if (firstDay == null) { // show just current week with today
			mList.add(new CalendarWeekRow(firstWeekDay, actualMonth, 1, getDayOfWeek(lastDay)));
		} else {
			while (lastWeekDay.compareTo(firstDay) >= 0) {
				int validDays = 7;
				int dayOffset = 0;

				if (lastWeekDay.compareTo(lastDay) > 0) { // first week
					validDays -= (getDayOfWeek(lastWeekDay) - getDayOfWeek(lastDay));
				}

				if (firstWeekDay.compareTo(firstDay) < 0) { // last week
					dayOffset = getDayOfWeek(firstDay);
					validDays -= (getDayOfWeek(firstDay) - getDayOfWeek(firstWeekDay));
				}

				if (firstWeekDay.get(Calendar.MONTH) != actualMonth && lastWeekDay.get(Calendar.MONTH) != actualMonth) {
					// month starts with monday 1st - jump to next month
					actualMonth = firstWeekDay.get(Calendar.MONTH);
					mList.add(new CalendarSectionRow(firstWeekDay.getTime()));
					mList.add(new CalendarWeekRow((Calendar) firstWeekDay.clone(), actualMonth, validDays, dayOffset));
					firstWeekDay.add(Calendar.DAY_OF_YEAR, -7);
					lastWeekDay.add(Calendar.DAY_OF_YEAR, -7);

				} else if (firstWeekDay.get(Calendar.MONTH) != actualMonth) { // part of week in current month
					mList.add(new CalendarWeekRow((Calendar) firstWeekDay.clone(), actualMonth, validDays, dayOffset));
					actualMonth = firstWeekDay.get(Calendar.MONTH);

					if (dayOffset != 0) { // last row
						break;
					}

					mList.add(new CalendarSectionRow(firstWeekDay.getTime()));

				} else { // whole week in current month
					mList.add(new CalendarWeekRow((Calendar) firstWeekDay.clone(), actualMonth, validDays, dayOffset));
					firstWeekDay.add(Calendar.DAY_OF_YEAR, -7);
					lastWeekDay.add(Calendar.DAY_OF_YEAR, -7);
				}
			}
		}
		return mList;
	}

	@Override
	protected void onStartLoading() {
		if (mList != null) {
			deliverResult(mList);
		}

		if (takeContentChanged()) {
			forceLoad();
		} else if (mList == null) {
			forceLoad();
		}
	}

	@Override
	protected void onStopLoading() {
		cancelLoad();
	}

	@Override
	protected void onReset() {
		onStopLoading();
	}
}
