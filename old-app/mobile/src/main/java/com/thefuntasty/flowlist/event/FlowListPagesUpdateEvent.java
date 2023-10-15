package com.thefuntasty.flowlist.event;

public class FlowListPagesUpdateEvent {

	public boolean mRecreateAll = true;

	public FlowListPagesUpdateEvent(boolean recreateAll) {
		mRecreateAll = recreateAll;
	}
}
