package com.thefuntasty.flowlist.activity;

import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.text.TextUtils;
import android.widget.Toast;

import com.afollestad.materialdialogs.MaterialDialog;
import com.crashlytics.android.Crashlytics;
import com.facebook.Request;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.model.GraphUser;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.BuildConfig;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.api.Api;
import com.thefuntasty.flowlist.dialog.SkipLoginDialog;
import com.thefuntasty.flowlist.model.Login;
import com.thefuntasty.flowlist.model.User;
import com.thefuntasty.flowlist.tool.FlowGoogleAnalytics;
import com.thefuntasty.flowlist.tool.FlowToast;
import com.thefuntasty.taste.res.TRes;

import butterknife.ButterKnife;
import butterknife.OnClick;
import io.fabric.sdk.android.Fabric;
import retrofit.Callback;
import retrofit.RetrofitError;
import retrofit.client.Response;


public class LoginActivity extends FragmentActivity {
	private static final String SCREEN_NAME = TRes.string(R.string.screen_login);
	private MaterialDialog mProgressDialog;

	@OnClick(R.id.login_btn_password) void onEmailBtnClick() {
		Intent intent = new Intent(this, EmailLoginActivity.class);
		startActivity(intent);
	}

	@OnClick(R.id.login_btn_facebook) void onFacebookBtnClick() {
		Session.openActiveSession(this, true, new Session.StatusCallback() {
			@Override
			public void call(final Session session, SessionState state, Exception exception) {
				if (session.isOpened()) {
					Request.newMeRequest(session, new Request.GraphUserCallback() {
						@Override
						public void onCompleted(final GraphUser user, com.facebook.Response response) {
							if (user != null) {
								runOnUiThread(new Runnable() {
									@Override
									public void run() {
										showProgressDialog();
									}
								});

								Api.get().loginFB(user.getId(), session.getAccessToken(), new Callback<Login>() {
									@Override
									public void success(final Login login, Response response) {
										getUserNameAndSave(login);
									}

									@Override
									public void failure(RetrofitError retrofitError) {
										FlowToast.showToast(R.string.cannot_log_in_fb_try_again, Toast.LENGTH_LONG);
										mProgressDialog.dismiss();
									}
								});
							}
						}
					}).executeAsync();
				}
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
				if (TextUtils.isEmpty(user.userImageUrl)) {
					editor.putString("userImage", user.getUserImageUrl());
				}
				editor.putInt("loginType", Login.FACEBOOK);
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

	@OnClick(R.id.skip_login) void skipLogin() {
		SkipLoginDialog.show(this, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				onActivityEnd();
			}
		});
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (Session.getActiveSession() != null) {
			Session.getActiveSession().onActivityResult(this, requestCode, resultCode, data);
		}
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		if (!BuildConfig.DEBUG) {
			Fabric.with(this, new Crashlytics());
		}

		setContentView(R.layout.activity_login);
		ButterKnife.bind(this);
	}

	@Override
	protected void onResume() {
		super.onResume();

		boolean skip = getIntent().getBooleanExtra("skip", true);

		if (!App.isFirstRun() && skip) {
			Intent intent = new Intent(this, BaseDrawerActivity.class);
			startActivity(intent);
			finish();
		} else {
			FlowGoogleAnalytics.screen(SCREEN_NAME);
		}
	}

	@Override
	protected void onStop() {
		super.onStop();
		if (mProgressDialog != null) {
			mProgressDialog.dismiss();
		}
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
