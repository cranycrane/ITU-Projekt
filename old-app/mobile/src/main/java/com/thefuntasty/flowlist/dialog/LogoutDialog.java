package com.thefuntasty.flowlist.dialog;

import android.content.Context;
import android.content.DialogInterface;
import android.support.v7.app.AlertDialog;

import com.thefuntasty.flowlist.R;
import com.thefuntasty.taste.res.TRes;

public class LogoutDialog {
	private LogoutDialog() {
	}

	public static void show(Context context, DialogInterface.OnClickListener onLogout) {
		AlertDialog.Builder builder = new AlertDialog.Builder(context, R.style.Theme_AppCompat_Light_Dialog);
		builder.setMessage(TRes.string(R.string.really_want_log_out));
		builder.setNegativeButton(TRes.string(R.string.cancel), new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});
		builder.setPositiveButton(TRes.string(R.string.logout), onLogout);

		builder.create().show();
	}

}
