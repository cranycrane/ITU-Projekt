package com.thefuntasty.flowlist.model;

import java.util.Date;

public abstract class FlowListItem {
	public abstract boolean isFlowDay();

	public static class FlowListDay extends FlowListItem {

		public long mMillis;
		public FlowDay mDay;

		public FlowListDay(FlowDay day, long millis) {
			mDay = day;
			mMillis = millis;
		}

		@Override
		public boolean isFlowDay() {
			return true;
		}
	}

	public static class FlowListInterval extends FlowListItem {

		public Date mFirstDay;
		public Date mLastDay;

		public FlowListInterval(Date firstDay, Date lastDay) {
			mFirstDay = firstDay;
			mLastDay = lastDay;
		}

		@Override
		public boolean isFlowDay() {
			return false;
		}
	}
}