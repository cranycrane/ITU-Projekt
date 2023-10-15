package com.thefuntasty.flowlist.activity;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.EditText;
import android.widget.Toast;

import com.afollestad.materialdialogs.MaterialDialog;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.api.Api;
import com.thefuntasty.flowlist.model.Login;
import com.thefuntasty.flowlist.model.User;
import com.thefuntasty.flowlist.tool.FlowGoogleAnalytics;
import com.thefuntasty.flowlist.tool.FlowToast;
import com.thefuntasty.taste.res.TRes;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import retrofit.Callback;
import retrofit.RetrofitError;
import retrofit.client.Response;

public class EmailLoginActivity extends Activity {

	private static final String SCREEN_NAME = TRes.string(R.string.screen_email_login);

	@BindView(R.id.login_name)
	EditText mLoginName;
	@BindView(R.id.login_password)
	EditText mLoginPassword;

	private MaterialDialog mProgressDialog;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_email_login);
		ButterKnife.bind(this);
		FlowGoogleAnalytics.screen(SCREEN_NAME);
	}

	@Override
	protected void onStop() {
		super.onStop();
		if (mProgressDialog != null) {
			mProgressDialog.dismiss();
		}
	}

	@OnClick(R.id.login_btn_password) void onPasswordBtnClick() {
		if (mLoginName.getEditableText().toString().trim().isEmpty()) {
			FlowToast.showToast(R.string.empty_username, Toast.LENGTH_LONG);
			return;
		}

		if (mLoginPassword.getEditableText().toString().trim().isEmpty()) {
			FlowToast.showToast(R.string.empty_password, Toast.LENGTH_LONG);
			return;
		}

		showProgressDialog();

		Api.get().loginEmail(mLoginName.getEditableText().toString(), mLoginPassword.getEditableText().toString(),
				new Callback<Login>() {
					@Override
					public void success(final Login login, Response response) {
						getUserNameAndSave(login);
					}

					@Override
					public void failure(RetrofitError retrofitError) {
						mProgressDialog.dismiss();
						FlowToast.showToast(R.string.cannot_log_in_check_name_pass, Toast.LENGTH_LONG);
					}
				});
	}

	private void showProgressDialog() {
		mProgressDialog = new MaterialDialog.Builder(this)
				.content(TRes.string(R.string.logging_in))
				.progress(true, 0)
				.cancelable(false)
				.show();
	}

	private void getUserNameAndSave(final Login login) {
		Api.get().getUserInfo(login.userId, login.accessToken, new Callback<User>() {
			@Override
			public void success(User user, Response response) {
				SharedPreferences.Editor editor =
						getSharedPreferences(TRes.string(R.string.preferences), MODE_PRIVATE).edit();

				editor.putString("token", login.accessToken);
				editor.putInt("userId", login.userId);
				editor.putString("userName", user.name.toUpperCase());
				if (user.userImageUrl != null && !user.userImageUrl.isEmpty()) {
					editor.putString("userImage", user.getUserImageUrl());
				}
				editor.putInt("loginType", Login.EMAIL);
				editor.putString("lastSyncTime", "2000-01-01 00:00");
				editor.apply();
				mProgressDialog.dismiss();

				App.forceSync();
				onActivityEnd();
			}

			@Override
			public void failure(RetrofitError error) {
				mProgressDialog.dismiss();
				FlowToast.showToast(R.string.cannot_log_in_connection_failed, Toast.LENGTH_LONG);
			}
		});
	}

	public void onActivityEnd() {
		if (App.isFirstRun()) {
			App.setNotFirstRun();
		}

		Intent intent = new Intent(this, BaseDrawerActivity.class);
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
		startActivity(intent);
		finish();
	}
}
