package com.thefuntasty.flowlist.task;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.util.Log;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.api.Api;
import com.thefuntasty.flowlist.event.SyncInProgressEvent;
import com.thefuntasty.flowlist.model.DataStore;
import com.thefuntasty.flowlist.model.FlowDay;
import com.thefuntasty.flowlist.model.Login;
import com.thefuntasty.flowlist.model.User;
import com.thefuntasty.taste.res.TRes;

import java.util.ArrayList;
import java.util.List;

import retrofit.Callback;
import retrofit.RetrofitError;
import retrofit.client.Response;

public class SyncTask extends AsyncTask<Void, Void, Void> {

	boolean mSyncAll;
	boolean mPullToRefresh;
	DataStore mStore;
	private final Callback<List<FlowDay>> sendRecordsCallback = new Callback<List<FlowDay>>() {
		@Override
		public void success(List<FlowDay> flowDays, Response response) {
			mStore.processData(flowDays);
			mStore.notifyDataSetChanged();
			// sync finished
		}

		@Override
		public void failure(RetrofitError retrofitError) {
			Log.e("Sync", "Failed to send records.");
		}
	};
	private final Callback<List<FlowDay>> getRecordsCallback = new Callback<List<FlowDay>>() {
		@Override
		public void success(List<FlowDay> flowDays, Response response) {
				mStore.processData(flowDays);

				// now send dirty/newer data to server
				ArrayList<FlowDay> dirtyDays = mStore.queryDirty();
				if (dirtyDays.size() != 0) {
					Api.get().sendRecords(Login.getUserId(), Login.getUserToken(), Login.getDeviceID(), dirtyDays, sendRecordsCallback);
				} else {
					if (flowDays != null && flowDays.size() != 0) { // no dirty data + received data non-empty
						mStore.notifyDataSetChanged();
					}
				}
				App.setLastSyncNow();
			App.bus().post(new SyncInProgressEvent(false, mPullToRefresh));
		}

		@Override
		public void failure(RetrofitError retrofitError) {
			Api.handleError(retrofitError);
			App.bus().post(new SyncInProgressEvent(false, mPullToRefresh));
		}
	};

	public SyncTask(boolean syncAll, boolean pullToRefresh) {
		mSyncAll = syncAll;
		mPullToRefresh = pullToRefresh;
		mStore = App.getStore();
	}

	@Override
	protected Void doInBackground(Void... params) {
		if (Login.userLoggedIn()) {
			final Login login = Login.getUserLogin();
			if (mSyncAll) {
				Api.get().getNewerRecords(login.userId, login.accessToken, "2000-01-01 00:00", getRecordsCallback);
			} else {
				Api.get().getNewerRecords(login.userId, login.accessToken, App.getLastSyncTime(), getRecordsCallback);
			}
			// Update users profile name & picture
			Api.get().getUserInfo(login.userId, login.accessToken, new Callback<User>() {
				@Override
				public void success(User user, Response response) {
					SharedPreferences.Editor editor = App.getContext().getSharedPreferences(TRes.string(R.string.preferences), Context.MODE_PRIVATE).edit();
					editor.putString("userName", user.name.toUpperCase());
					if (user.userImageUrl != null && !user.userImageUrl.isEmpty()) {
						editor.putString("userImage", user.getUserImageUrl());
					}
					editor.apply();
				}

				@Override
				public void failure(RetrofitError error) {
				}
			});
		} else {
			App.bus().post(new SyncInProgressEvent(false, mPullToRefresh));
		}
		return null;
	}
}
