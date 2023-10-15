package com.thefuntasty.flowlist.model;

import com.activeandroid.ActiveAndroid;
import com.google.gson.annotations.Expose;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.api.Api;
import com.thefuntasty.flowlist.database.ActiveDatabase;
import com.thefuntasty.flowlist.event.FlowListPagesUpdateEvent;
import com.thefuntasty.flowlist.task.SyncTask;
import com.thefuntasty.flowlist.tool.DateUtil;
import com.thefuntasty.flowlist.tool.Util;
import com.thefuntasty.taste.res.TRes;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.TreeMap;
import java.util.concurrent.TimeUnit;

import retrofit.Callback;
import retrofit.RetrofitError;
import retrofit.client.Response;

public class DataStore {
	@Expose
	private final Calendar mCalendar;
	@Expose
	private final TreeMap<Long, FlowDay> days;
	@Expose
	private final ArrayList<FlowListItem> mItems;
	@Expose
	private final ActiveDatabase mDBAccess;
	@Expose
	private int mDefaultDataPos;
	@Expose
	private long mDefaultMillis;
	@Expose
	private long mIntervalFirstMillis;
	@Expose
	private long mIntervalLastMillis;

	public DataStore() {
		mDBAccess = new ActiveDatabase();
		days = mDBAccess.queryAll();
		mCalendar = DateUtil.getCal();
		mItems = new ArrayList<>();
	}

	public static boolean isToday(long when) {
		GregorianCalendar date = (GregorianCalendar) GregorianCalendar.getInstance(TimeZone.getTimeZone("UTC"));
		date.setTimeInMillis(when);

		GregorianCalendar actualDate = (GregorianCalendar) GregorianCalendar.getInstance(TimeZone.getTimeZone("UTC"));

		return (date.get(Calendar.ERA) == actualDate.get(Calendar.ERA) &&
				date.get(Calendar.YEAR) == actualDate.get(Calendar.YEAR) &&
				date.get(Calendar.DAY_OF_YEAR) == actualDate.get(Calendar.DAY_OF_YEAR));

	}

	public void notifyDataSetChanged() {
		mItems.clear();
		setDefaultDataPos(mDefaultMillis, mIntervalFirstMillis, mIntervalLastMillis);
		App.bus().post(new FlowListPagesUpdateEvent(true));
	}

	public void notifyCurrentDayChanged() {
		App.bus().post(new FlowListPagesUpdateEvent(false));
	}

	public void deleteAll() {
		days.clear();
		mItems.clear();
		mDBAccess.deleteAll();
		notifyDataSetChanged();
	}

	public ArrayList<FlowDay> queryDirty() {
		return mDBAccess.queryDirty();
	}

	public FlowDay getDay(long millis) {
		if (days == null || days.isEmpty()) return null;

		return days.get(millis);
	}

	public FlowDay getToday() {
		return mDBAccess.queryToday();
	}

	public boolean addDay(final FlowDay day, long millis, int state) {
		day.state = state;
		if (state != ActiveDatabase.STATE_SYNCED) day.lastEdit = DateUtil.getTimeStamp();
		if (day.isEmpty()) day.skipped = true;

		days.put(millis, day);
		// TODO save data in one transaction
		mDBAccess.insert(day);
		if (state != ActiveDatabase.STATE_SYNCED && Login.userLoggedIn()) {
			Api.get().sendRecord(Login.getUserId(), Login.getUserToken(), Login.getDeviceID(), day.day, day, new Callback<FlowDay>() {
				@Override
				public void success(FlowDay flowDay, Response response) {
					processData(Collections.singletonList(flowDay));
					notifyCurrentDayChanged();
				}

				@Override
				public void failure(RetrofitError e) {
					Api.handleError(e);
				}
			});
		}
		return state != ActiveDatabase.STATE_SYNCED;
	}

	public boolean addDay(FlowDay day, int state) {
		return addDay(day, DateUtil.dateToMillis(day.day), state);
	}

	public void addDays(List<FlowDay> days, int state) {
		for (FlowDay day : days) {
			day.state = state;
			if (state != ActiveDatabase.STATE_SYNCED) day.lastEdit = DateUtil.getTimeStamp();
			this.days.put(DateUtil.dateToMillis(day.day), day);
		}
		mDBAccess.insertBulk(days);
		notifyDataSetChanged();
	}

	public boolean updateDay(final FlowDay localDayData, FlowDay newDayData, int state) {
		FlowDay.copyData(localDayData, newDayData);
		localDayData.state = state;
		if (state != ActiveDatabase.STATE_SYNCED) localDayData.lastEdit = DateUtil.getTimeStamp();
		if (localDayData.isEmpty()) localDayData.skipped = true;

		mDBAccess.update(localDayData);
		if (state != ActiveDatabase.STATE_SYNCED && Login.userLoggedIn()) {
			Api.get().sendRecord(Login.getUserId(), Login.getUserToken(), Login.getDeviceID(), localDayData.day, localDayData, new Callback<FlowDay>() {
				@Override
				public void success(FlowDay flowDay, Response response) {
					if (!Util.equals(localDayData.lastEdit, flowDay.lastEdit)) {
						processData(Collections.singletonList(flowDay));
						notifyCurrentDayChanged();
					}
				}

				@Override
				public void failure(RetrofitError e) {
					Api.handleError(e);
				}
			});
		}
		return state != ActiveDatabase.STATE_SYNCED;
	}

	public boolean updateDay(FlowDay newDayData, int state) {
		long millis = DateUtil.dateToMillis(newDayData.day);

		return updateDay(getDay(millis), newDayData, state);
	}

	/**
	 * Method for data sync:
	 * 1) Check token validity
	 * 2) Load data from server and save to local database
	 * 3) Get dirty local data and send to server
	 * 4) Process server response and save to local database
	 *
	 * @param syncAll If true, all user data are synced. If false only data with lastEdit > getLastSyncTime()
	 *                are downloaded and processed.
	 */
	public void sync(final boolean syncAll) {
		new SyncTask(syncAll, false).execute();
	}

	public void sync(final boolean syncAll, boolean pullToRefresh) {
		new SyncTask(syncAll, pullToRefresh).execute();
	}

	public void processData(List<FlowDay> serverDays) {
		boolean needUpdate = false;
		ActiveAndroid.beginTransaction();
		try {
			if (serverDays != null) {
				for (FlowDay serverDay : serverDays) {

					long millis = DateUtil.dateToMillis(serverDay.day);
					FlowDay localDay = getDay(millis);

					if (localDay == null) { // new record, just save it
						needUpdate |= addDay(serverDay, millis, ActiveDatabase.STATE_SYNCED);
					} else {
						needUpdate |= updateDay(localDay, serverDay, ActiveDatabase.STATE_SYNCED);
					}
				}
			}
			ActiveAndroid.setTransactionSuccessful();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			ActiveAndroid.endTransaction();
		}
		if (needUpdate) notifyDataSetChanged();
	}

	private FlowListItem getFlowListItem(long millis) {
		FlowDay day = getDay(millis);
		if (isExpanded()) {
			if (millis >= mIntervalFirstMillis && millis <= mIntervalLastMillis) {
				return new FlowListItem.FlowListDay(day, millis);
			} else {
				return null;
			}
		}

		if (day == null || day.skipped) {
			if (isToday(millis)) {
				return new FlowListItem.FlowListDay(day, millis); // today
			} else if (DateUtil.getCal().getTimeInMillis() < millis) { // future
				return null;
			} else {
				Map.Entry<Long, FlowDay> firstEntry;
				Map.Entry<Long, FlowDay> lastEntry;

				// look for first non skipped day
				do {
					firstEntry = days.lowerEntry(millis);
					millis -= TimeUnit.DAYS.toMillis(1);
				}
				while (firstEntry != null && firstEntry.getValue().skipped);

				do {
					lastEntry = days.higherEntry(millis);
					millis += TimeUnit.DAYS.toMillis(1);
				}
				while (lastEntry != null && lastEntry.getValue().skipped);


				if (firstEntry == null) { // past
					return null;
				} else {
					mCalendar.setTimeInMillis(firstEntry.getKey());
					mCalendar.add(Calendar.DATE, 1);
					Date firstDate = mCalendar.getTime();

					mCalendar.setTimeInMillis(lastEntry == null ?
							DateUtil.getCal().getTimeInMillis() : lastEntry.getKey());
					mCalendar.add(Calendar.DATE, -1);
					Date lastDate = mCalendar.getTime();

					if (firstDate.compareTo(lastDate) == 0) {
						return new FlowListItem.FlowListDay(null, firstDate.getTime());
					}

					return new FlowListItem.FlowListInterval(firstDate, lastDate);
				}
			}
		} else {
			return new FlowListItem.FlowListDay(day, millis);
		}
	}

	public FlowListItem getFlowListItem(int position, int defaultPage) {
		int dataPos = positionToDataPosition(position, defaultPage);
		if (dataPos < 0) {
			dataPos *= -1;
			for (int i = 0; i < dataPos; i++) {
				FlowListItem item = mItems.get(0);
				if (item == null) {
					mItems.add(0, null);
				} else if (item instanceof FlowListItem.FlowListDay) {
					mItems.add(0, getFlowListItem(((FlowListItem.FlowListDay) item).mMillis + TimeUnit.DAYS.toMillis(1)));
				} else if (item instanceof FlowListItem.FlowListInterval) {
					mItems.add(0, getFlowListItem(
							((FlowListItem.FlowListInterval) item).mLastDay.getTime() + TimeUnit.DAYS.toMillis(1)));
				} else {
					throw new RuntimeException("getFlowListItem(): Pos:" + String.valueOf(position));
				}

				mDefaultDataPos++;
			}
			return mItems.get(0);

		} else if (dataPos >= mItems.size()) {
			int iter = dataPos - (mItems.size() - 1);
			for (int i = 0; i < iter; i++) {
				FlowListItem item = mItems.get(mItems.size() - 1);
				if (item == null) {
					mItems.add(null);
				} else if (item instanceof FlowListItem.FlowListDay) {
					mItems.add(getFlowListItem(
							((FlowListItem.FlowListDay) item).mMillis - TimeUnit.DAYS.toMillis(1)));
				} else if (item instanceof FlowListItem.FlowListInterval) {
					mItems.add(getFlowListItem(
							((FlowListItem.FlowListInterval) item).mFirstDay.getTime() - TimeUnit.DAYS.toMillis(1)));
				} else {
					throw new RuntimeException("getFlowListItem(): Pos:" + String.valueOf(position));
				}
			}
			return mItems.get(mItems.size() - 1);
		}

		return mItems.get(dataPos);
	}

	public String getTitle(int position, int defaultPage) {
		int dataPos = positionToDataPosition(position, defaultPage);
		FlowListItem item = mItems.get(dataPos);
		if (item == null) {
			return "";
		} else if (item instanceof FlowListItem.FlowListDay) {
			mCalendar.setTimeInMillis(((FlowListItem.FlowListDay) item).mMillis);
			if (isToday(((FlowListItem.FlowListDay) item).mMillis)) {
				return TRes.string(R.string.today);
			} else if (isToday(((FlowListItem.FlowListDay) item).mMillis + TimeUnit.DAYS.toMillis(1))) {
				return TRes.string(R.string.yesterday);
			} else {
				return DateUtil.dateToShortString(mCalendar.getTime()).toUpperCase();
			}
		} else if (item instanceof FlowListItem.FlowListInterval) {
			return "• • •";
		} else {
			throw new RuntimeException("getFlowListItem(): Pos:" + String.valueOf(position));
		}
	}

	public void setDefaultDataPos(long millis) {
		mDefaultDataPos = 0;
		mDefaultMillis = millis;
		mIntervalFirstMillis = 0;
		mIntervalLastMillis = 0;

		mItems.clear();
		mItems.add(getFlowListItem(millis));
	}

	public void setDefaultDataPos(long millis, long minimum, long maximum) {
		mDefaultDataPos = 0;
		mDefaultMillis = millis;
		mIntervalFirstMillis = minimum;
		mIntervalLastMillis = maximum;

		mItems.clear();
		mItems.add(getFlowListItem(millis));
	}

	public boolean isExpanded() {
		return (mIntervalFirstMillis + mIntervalFirstMillis) != 0;
	}

	/**
	 * Method to translate ViewPager's page position to data position
	 *
	 * @param position    page position
	 * @param defaultPage default page position in viewPager
	 * @return return data position
	 */
	public int positionToDataPosition(int position, int defaultPage) {
		int temp = defaultPage - position;
		return mDefaultDataPos + temp;
	}

	public Calendar getFirstDayCal() {
		Calendar cal = DateUtil.getCal();
		if (!days.isEmpty()) {
			for (Long key : days.keySet()) {
				FlowDay day = days.get(key);
				if (day != null && !day.skipped) {
					cal.setTimeInMillis(key);
					return cal;
				}
			}
			return null;
		}
		return null;
	}
}
