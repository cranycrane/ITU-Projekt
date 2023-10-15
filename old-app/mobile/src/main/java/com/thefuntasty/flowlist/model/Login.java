package com.thefuntasty.flowlist.model;

import android.content.Context;
import android.content.SharedPreferences;
import android.provider.Settings;

import com.google.gson.annotations.Expose;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.taste.res.TRes;

public class Login {

	public static final int EMAIL = 1;
	public static final int FACEBOOK = 2;

	public static final int USER_INVALID = -1;
	public static final int TYPE_INVALID = -1;

	@Expose
	public int userId;
	@Expose
	public String accessToken;
	@Expose
	public int type;

	public static Login getUserLogin() {
		Context context = App.getContext();
		SharedPreferences sh = context.getSharedPreferences(
				TRes.string(R.string.preferences), Context.MODE_PRIVATE);
		Login login = new Login();
		login.accessToken = sh.getString("token", "");
		login.userId = sh.getInt("userId", Login.USER_INVALID);
		login.type = sh.getInt("loginType", Login.TYPE_INVALID);
		return login;
	}

	public static Boolean userLoggedIn() {
		final Login login = Login.getUserLogin();
		return login.userId != Login.USER_INVALID && !login.accessToken.isEmpty();
	}

	public static int getUserId() {
		Context context = App.getContext();
		SharedPreferences sh = context.getSharedPreferences(
				TRes.string(R.string.preferences), Context.MODE_PRIVATE);
		return sh.getInt("userId", Login.USER_INVALID);
	}

	public static String getUserToken() {
		Context context = App.getContext();
		SharedPreferences sh = context.getSharedPreferences(
				TRes.string(R.string.preferences), Context.MODE_PRIVATE);
		return sh.getString("token", "");
	}

	public static String getUserName() {
		Context context = App.getContext();
		SharedPreferences sh = context.getSharedPreferences(
				TRes.string(R.string.preferences), Context.MODE_PRIVATE);
		return sh.getString("userName", "");
	}

	public static String getUserImage() {
		Context context = App.getContext();
		SharedPreferences sh = context.getSharedPreferences(
				TRes.string(R.string.preferences), Context.MODE_PRIVATE);
		return sh.getString("userImage", "");
	}

	public static void removeUserLogin() {
		Context context = App.getContext();
		SharedPreferences sh = context.getSharedPreferences(
				TRes.string(R.string.preferences), Context.MODE_PRIVATE);

		int oldUserId = sh.getInt("userId", -1);

		SharedPreferences.Editor editor = sh.edit();
		editor.remove("token");
		editor.remove("userId");
		editor.remove("loginType");
		editor.remove("lastSyncTime");
		editor.remove("userName");
		editor.remove("userImage");

		// remember old ID
		editor.putInt("oldUserId", oldUserId);
		editor.apply();
	}

	public static boolean loggedWithNewAccount() {
		Context context = App.getContext();
		SharedPreferences sh = context.getSharedPreferences(
				TRes.string(R.string.preferences), Context.MODE_PRIVATE);

		int userID = sh.getInt("userId", -1);
		int oldUserId = sh.getInt("oldUserId", -1);

		// logged in for the first time
		return oldUserId != -1 && userID != oldUserId;

	}

	public static String getDeviceID() {
		return Settings.Secure.getString(App.getContext().getContentResolver(), Settings.Secure.ANDROID_ID);
	}
}
