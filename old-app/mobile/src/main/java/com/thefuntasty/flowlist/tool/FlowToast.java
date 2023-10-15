package com.thefuntasty.flowlist.tool;

import android.content.Context;
import android.support.annotation.StringRes;
import android.widget.Toast;

import com.thefuntasty.flowlist.App;

public class FlowToast {
	private FlowToast() {
	}

	public static void showToast(String message, int duration) {
		Context context = App.getContext();
		if (context != null) {
			Toast.makeText(context, message, duration).show();
		}
	}

	public static void showToast(@StringRes int stringResource, int duration) {
		Context context = App.getContext();
		if (context != null) {
			Toast.makeText(context, stringResource, duration).show();
		}
	}
}
