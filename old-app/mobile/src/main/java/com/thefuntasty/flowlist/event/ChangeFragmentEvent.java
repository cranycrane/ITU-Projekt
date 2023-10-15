package com.thefuntasty.flowlist.event;

public class ChangeFragmentEvent {
	public final int mFragmentID;
	public final long mData;

	public ChangeFragmentEvent(int fragmentID, long data) {
		mFragmentID = fragmentID;
		mData = data;
	}
}
