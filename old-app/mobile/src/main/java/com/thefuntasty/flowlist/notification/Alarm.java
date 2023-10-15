package com.thefuntasty.flowlist.notification;

import android.app.AlarmManager;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import java.util.Calendar;

public class Alarm {

	private static final String TAG = Alarm.class.getSimpleName();

	private final Context mContext;

	public Alarm(Context context) {
		mContext = context;

		Calendar calendar = Calendar.getInstance();
		calendar.set(Calendar.HOUR_OF_DAY, 18);
		calendar.set(Calendar.MINUTE, 30);
		calendar.set(Calendar.SECOND, 0);
		calendar.set(Calendar.MILLISECOND, 0);


		// if it's after 19:00, we set alarm to tomorrow
		if (calendar.getTimeInMillis() <= System.currentTimeMillis()) {
			calendar.add(Calendar.HOUR_OF_DAY, 24);
		}

		planAlarm(calendar);
	}

	public Alarm(Context context, long delay) {
		mContext = context;

		NotificationManager manager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
		manager.cancel(AlarmService.NOTIFICATION_ID);

		Calendar calendar = Calendar.getInstance();
		calendar.add(Calendar.MILLISECOND, (int) delay); // safe - adding 1 or 2 hours

		planAlarm(calendar);
	}

	private void planAlarm(Calendar calendar) {
		AlarmManager manager = (AlarmManager) mContext.getSystemService(Context.ALARM_SERVICE);

		Intent intent = new Intent(mContext, AlarmService.class);
		PendingIntent pendingIntent = PendingIntent.getService(mContext, 0, intent, 0);

		manager.set(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(), pendingIntent);
	}
}
