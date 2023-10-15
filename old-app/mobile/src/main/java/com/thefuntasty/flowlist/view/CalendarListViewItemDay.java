package com.thefuntasty.flowlist.view;

import android.content.Context;
import android.graphics.Color;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.thefuntasty.flowlist.R;
import com.thefuntasty.taste.res.TRes;

public class CalendarListViewItemDay extends LinearLayout {

	private TextView mDayText;
	private TextView mDayNumber;

	public CalendarListViewItemDay(Context context) {
		super(context);
		init();
	}

	public CalendarListViewItemDay(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public CalendarListViewItemDay(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs);
		init();
	}

	private void init() {
		if (!isInEditMode()) {
			inflate(getContext(), R.layout.calendar_list_view_item_day, this);

			LayoutParams params = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1.0f);
			setLayoutParams(params);

			mDayNumber = (TextView) findViewById(R.id.calendar_item_day_number);
			mDayText = (TextView) findViewById(R.id.calendar_item_day_text);

			setOrientation(LinearLayout.VERTICAL);
			setWeightSum(1.0f);
			setGravity(Gravity.CENTER);
		}
	}

	private void setDayTextLightGray() {
		mDayText.setTextColor(TRes.color(R.color.deactivated_gray_text));
	}

	private void setDayTextDarkGray() {
		mDayText.setTextColor(TRes.color(R.color.light_gray));
	}

	private void setDayTextBlack() {
		mDayText.setTextColor(Color.BLACK);
	}

	private void setDayTextRed() {
		mDayText.setTextColor(TRes.color(R.color.main_red));
	}

	public void setDayNumberLightGray() {
		mDayNumber.setTextColor(TRes.color(R.color.deactivated_gray_text));
	}

	public void setDayNumberDarkGray() {
		mDayNumber.setTextColor(TRes.color(R.color.light_gray));
	}

	public void setDayNumberBlack() {
		mDayNumber.setTextColor(Color.BLACK);
	}

	private void setDayNumberRed() {
		mDayNumber.setTextColor(TRes.color(R.color.main_red));
	}

	public void setInactive() {
		setDayTextLightGray();
		setDayNumberLightGray();
	}

	public void setAvailable() {
		setDayTextDarkGray();
		setDayNumberDarkGray();
	}

	public void setFilled() {
		setDayTextBlack();
		setDayNumberBlack();
	}

	public void setStarred() {
		setDayTextRed();
		setDayNumberRed();
	}

	public void setDayNumber(String dayNumber) {
		mDayNumber.setText(dayNumber);
	}

	public void setDayText(String dayText) {
		mDayText.setText(dayText);
	}
}
