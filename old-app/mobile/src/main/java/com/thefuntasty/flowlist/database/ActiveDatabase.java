package com.thefuntasty.flowlist.database;

import android.util.Log;

import com.activeandroid.ActiveAndroid;
import com.activeandroid.query.Select;

import com.thefuntasty.flowlist.model.FlowDay;
import com.thefuntasty.flowlist.tool.DateUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class ActiveDatabase {

	public static final int STATE_SYNCED = 1;
	public static final int STATE_DIRTY = 2;
	private static final String TAG = ActiveDatabase.class.getSimpleName();

	public TreeMap<Long, FlowDay> queryAll() {
		List<FlowDay> daysList = new Select().from(FlowDay.class).execute();
		Map<Long, FlowDay> daysMap = new TreeMap<>();

		for (FlowDay day : daysList) {
			daysMap.put(DateUtil.dateToMillis(day.day), day);
		}

		return (TreeMap<Long, FlowDay>) daysMap;
	}

	public ArrayList<FlowDay> queryDirty() {
		List<FlowDay> days;
		days = new Select().from(FlowDay.class).where("state = " + STATE_DIRTY).orderBy("day ASC").execute();

		return (ArrayList<FlowDay>) days;
	}

	public void deleteAll() {
		ActiveAndroid.execSQL("delete from flow_days;");
	}

	public FlowDay queryToday() {
		return new Select().from(FlowDay.class).where("day == ?", DateUtil.dateToDBString(DateUtil.getCal().getTime())).executeSingle();
	}

	public void insert(FlowDay day) {
		day.save();
	}

	public void insertBulk(List<FlowDay> days) {
		ActiveAndroid.beginTransaction();
		try {
			for (FlowDay day : days) {
				day.save();
			}
			ActiveAndroid.setTransactionSuccessful();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			ActiveAndroid.endTransaction();
		}
	}

	public void update(FlowDay day) {
		if (day.getId() == null) {
			Log.e(TAG, "Updating without ID -> needed!");
		} else {
			day.save();
		}
	}
}
