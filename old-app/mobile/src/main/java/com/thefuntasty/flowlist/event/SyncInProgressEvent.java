package com.thefuntasty.flowlist.event;

public class SyncInProgressEvent {

	public final boolean mIsRunning;
	public boolean mPullToRefresh = false;

	public SyncInProgressEvent(boolean isRunning, boolean pullToRefresh) {
		mIsRunning = isRunning;
		mPullToRefresh = pullToRefresh;
	}
}
