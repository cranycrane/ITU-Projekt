package com.thefuntasty.flowlist.dialog;

import android.content.Context;
import android.content.DialogInterface;
import android.support.v7.app.AlertDialog;

import com.thefuntasty.flowlist.R;
import com.thefuntasty.taste.res.TRes;

public class SaveDialog {
	private SaveDialog() {
	}

	public static void show(Context context, DialogInterface.OnClickListener onSave, DialogInterface.OnClickListener onThrowOut) {
		AlertDialog.Builder builder = new AlertDialog.Builder(context, R.style.Theme_AppCompat_Light_Dialog);
		builder.setMessage(TRes.string(R.string.save_changes));
		builder.setNegativeButton(TRes.string(R.string.cancel), new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				dialog.dismiss();
			}
		});
		builder.setNeutralButton(TRes.string(R.string.throw_out), onThrowOut);
		builder.setPositiveButton(TRes.string(R.string.save), onSave);
		builder.create().show();
	}
}
