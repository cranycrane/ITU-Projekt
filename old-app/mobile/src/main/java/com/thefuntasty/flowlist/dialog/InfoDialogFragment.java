package com.thefuntasty.flowlist.dialog;

import android.app.Dialog;
import android.os.Bundle;
import android.support.annotation.LayoutRes;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;

import com.thefuntasty.flowlist.R;

public class InfoDialogFragment extends DialogFragment {

	public static DialogFragment newInstance(@LayoutRes int layout) {
		InfoDialogFragment d = new InfoDialogFragment();

		Bundle bundle = new Bundle();
		bundle.putInt("layout", layout);
		d.setArguments(bundle);

		return d;
	}

	@NonNull
	@Override
	public Dialog onCreateDialog(Bundle savedInstanceState) {
		final Dialog dialog = new Dialog(getActivity(), android.R.style.Theme_Translucent);
		dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
		dialog.setContentView(getArguments().getInt("layout"));
		dialog.getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

		dialog.findViewById(R.id.content).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				dialog.dismiss();
			}
		});

		return dialog;
	}
}
