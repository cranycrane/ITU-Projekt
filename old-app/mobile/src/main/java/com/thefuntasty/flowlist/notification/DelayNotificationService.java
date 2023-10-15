package com.thefuntasty.flowlist.notification;

import android.app.IntentService;
import android.content.Intent;

import java.util.concurrent.TimeUnit;

public class DelayNotificationService extends IntentService {

	public DelayNotificationService() {
		super("DelayNotificationService");
	}

	@Override
	protected void onHandleIntent(Intent intent) {
		new Alarm(getApplicationContext(), intent.getLongExtra("delay", TimeUnit.HOURS.toMillis(1)));
	}
}
