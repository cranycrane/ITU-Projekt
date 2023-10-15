package com.thefuntasty.flowlist;

import android.content.Context;
import android.content.SharedPreferences;

import com.activeandroid.ActiveAndroid;

import com.thefuntasty.flowlist.model.DataStore;
import com.thefuntasty.flowlist.model.Login;
import com.thefuntasty.flowlist.notification.Alarm;
import com.thefuntasty.flowlist.tool.DateUtil;
import com.thefuntasty.flowlist.tool.FlowGoogleAnalytics;
import com.thefuntasty.taste.Taste;
import com.thefuntasty.taste.bus.TBus;
import com.thefuntasty.taste.locale.TLocale;
import com.thefuntasty.taste.res.TRes;

public class App extends com.activeandroid.app.Application {
	public static int mDrawerPosition = 0;
	public static Boolean mDrawerVisible = false;
	private static TBus mBus;
	private static DataStore mDataStore;
	private static App mInstance;
	private static SharedPreferences mSharedPreferences;

	public static void forceSync() {
		if (Login.loggedWithNewAccount()) {
			mDataStore.deleteAll();
		}

		App.getStore().sync(true);
	}

	public static Context getContext() {
		return mInstance.getBaseContext();
	}

	public static String getLastSyncTime() {
		return mSharedPreferences.getString("lastSyncTime", "2000-01-01 00:00");
	}

	public static void setLastSyncNow() {
		SharedPreferences.Editor editor = mSharedPreferences.edit();
		String timeStamp = DateUtil.getTimeStamp();
		editor.putString("lastSyncTime", timeStamp.substring(0, 16));
		editor.apply();
	}

	public static boolean isFirstRun() {
		return mSharedPreferences.getBoolean("firstRun", true);
	}

	public static void setNotFirstRun() {
		mSharedPreferences.edit().putBoolean("firstRun", false).apply();
	}

	public static DataStore getStore() {
		return mDataStore;
	}

	public static TBus bus() {
		return mBus;
	}

	@Override
	public void onCreate() {
		super.onCreate();
		Taste.init(this);
		new Alarm(this);
		ActiveAndroid.initialize(this);

		mInstance = this;
		FlowGoogleAnalytics.init(this);
		mBus = new TBus();
		mSharedPreferences = getContext().getSharedPreferences(
				TRes.string(R.string.preferences), MODE_PRIVATE);
		mDataStore = new DataStore();
		App.getStore().sync(false);
		TLocale.set(TRes.string(R.string.locale_language), TRes.string(R.string.locale_country));
	}
}
