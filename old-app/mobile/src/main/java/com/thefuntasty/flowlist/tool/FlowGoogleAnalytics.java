package com.thefuntasty.flowlist.tool;

import android.app.Application;

import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.Tracker;

import com.thefuntasty.flowlist.R;
import com.thefuntasty.taste.res.TRes;

public class FlowGoogleAnalytics {
	private static Tracker tracker;

	private FlowGoogleAnalytics() {
	}

	public static void init(Application application) {
		if (tracker == null) {
			GoogleAnalytics ga = GoogleAnalytics.getInstance(application);
			ga.enableAutoActivityReports(application);
			tracker = ga.newTracker(TRes.string(R.string.ga_tracking_id));
			tracker.enableAdvertisingIdCollection(true);
			tracker.enableExceptionReporting(true);
			tracker.enableAutoActivityTracking(true);
		}
	}

	public static Tracker get() {
		return tracker;
	}


	public static void time(String category, String label, long time) {
		tracker.send(new HitBuilders.TimingBuilder()
				.setCategory(category)
				.setVariable(label)
				.setValue(time)
				.build());
	}

	public static void click(String where, String what) {
		tracker.send(new HitBuilders.EventBuilder()
				.setAction("Klik")
				.setCategory(where)
				.setLabel(what)
				.build());
	}

	public static void pullToRefresh(String where) {
		tracker.send(new HitBuilders.EventBuilder()
				.setAction("Pull to Refresh")
				.setCategory(where)
				.setLabel("Celá obrazovka")
				.build());
	}

	public static void display(String where, String what) {
		tracker.send(new HitBuilders.EventBuilder()
				.setAction("Zobrazení")
				.setCategory(where)
				.setLabel(what)
				.build());
	}

	public static void screen(String where) {
		display(where, "Celá obrazovka");
	}

	public static void screen(String where, String data) {
		display(where, data);
	}

}
