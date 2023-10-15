package com.thefuntasty.flowlist.notification;

import android.app.IntentService;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.support.v4.app.NotificationCompat;
import android.support.v4.content.IntentCompat;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.activity.BaseDrawerActivity;
import com.thefuntasty.flowlist.api.Api;
import com.thefuntasty.flowlist.model.FlowDay;
import com.thefuntasty.flowlist.model.Login;
import com.thefuntasty.flowlist.tool.DateUtil;
import com.thefuntasty.taste.res.TRes;

import java.util.concurrent.TimeUnit;

import retrofit.RetrofitError;

public class AlarmService extends IntentService {

	public static final int NOTIFICATION_ID = 555;
	private static final String TAG = AlarmService.class.getSimpleName();

	public AlarmService() {
		super(TAG);
	}

	@Override
	protected void onHandleIntent(Intent intent) {
		// set new alarm
		new Alarm(getApplicationContext());

		// check if today is in database
		FlowDay today = App.getStore().getToday();
		if (today == null || today.isEmpty()) {
			//Log.d(TAG, "Today empty in device");
			Login login = Login.getUserLogin();
			if (login.userId != Login.USER_INVALID) {
				//Log.d(TAG, "User valid");
				try {
					today = Api.get().getRecord(login.userId, login.accessToken, DateUtil.dateToDBString(DateUtil.getCal().getTime()));
					/*Log.d(TAG, "Today:" + (today != null ? "ok" : "null"));
					Log.d(TAG, "Today.isEmpty():" + today.isEmpty());
					Log.d(TAG, "Today.skipped:" + today.skipped);*/
					if (today == null || (today.isEmpty() && !today.skipped)) {
						//Log.d(TAG, "Today not available on server");
						createNotification();
					} /*else {
						Log.d(TAG, "Today on server");
					}*/
				} catch (RetrofitError e) {
					//Log.d(TAG, "No internet");
				}
			} else { // user not logged in
				//Log.d(TAG, "User not logged");
				createNotification();
			}
		}
	}

	private void createNotification() {
		NotificationCompat.Builder builder = new NotificationCompat.Builder(getApplicationContext());

		Intent intent = new Intent(getApplicationContext(), BaseDrawerActivity.class);
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | IntentCompat.FLAG_ACTIVITY_CLEAR_TASK);

		PendingIntent pendingIntent = PendingIntent.getActivity(
				this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);

		builder.setContentIntent(pendingIntent);
		builder.setSmallIcon(R.drawable.velka_bila);
		builder.setContentTitle(TRes.string(R.string.notification_title_text));
		builder.setContentText(TRes.string(R.string.notification_content_text));
		builder.setAutoCancel(true);

		Intent delayIntent = new Intent(this, DelayNotificationService.class);

		delayIntent.putExtra("delay", TimeUnit.HOURS.toMillis(1));

		PendingIntent delayPendingIntent = PendingIntent.getService(
				this, 1, delayIntent, PendingIntent.FLAG_CANCEL_CURRENT);

		builder.addAction(R.drawable.mala_bila, TRes.string(R.string.notification_action_remind_later), delayPendingIntent);

		NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
		manager.notify(NOTIFICATION_ID, builder.build());
	}
}
