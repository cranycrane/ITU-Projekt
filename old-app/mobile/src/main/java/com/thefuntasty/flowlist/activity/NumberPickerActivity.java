package com.thefuntasty.flowlist.activity;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.database.ActiveDatabase;
import com.thefuntasty.flowlist.model.FlowDay;
import com.thefuntasty.flowlist.tool.FlowGoogleAnalytics;
import com.thefuntasty.flowlist.tool.Util;
import com.thefuntasty.taste.res.TRes;

import net.simonvt.numberpicker.NumberPicker;

import butterknife.BindView;
import butterknife.ButterKnife;

public class NumberPickerActivity extends AppCompatActivity {
	public static final String DATE_EXTRA = "date";
	private static final String SCREEN_NAME = TRes.string(R.string.screen_score_picker);
	@BindView(R.id.numberPicker)
	NumberPicker mNumberPicker;
	long mMillis;
	FlowDay mDay;
	boolean mNewDay = false;
	boolean mNewScore;

	@Override
	protected void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_number_picker);
		ButterKnife.bind(this);
		FlowGoogleAnalytics.screen(SCREEN_NAME);
		getSupportActionBar().setDisplayHomeAsUpEnabled(true);

		mNumberPicker.setMinValue(1);
		mNumberPicker.setMaxValue(10);

		Bundle bundle = getIntent().getExtras();
		mMillis = bundle.getLong(DATE_EXTRA);

		mDay = App.getStore().getDay(mMillis);

		if (mDay == null) {
			mDay = new FlowDay(mMillis);
			mNewDay = true;
		}

		mNewScore = mDay.score == null;

		mNumberPicker.setValue(mNewScore ? 10 : mDay.score);
		mNumberPicker.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				saveDayScore();
			}
		});
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.number_picker_menu, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			case R.id.action_save:
				saveDayScore();
				return true;
			case android.R.id.home:
				saveDayScore();
				return true;
			default:
				return super.onOptionsItemSelected(item);
		}
	}

	void saveDayScore() {
		Integer value = mNumberPicker.getValue();
		if (!Util.equals(mDay.score, value)) {
			if (mNewScore) {
				FlowGoogleAnalytics.click(SCREEN_NAME, TRes.string(R.string.click_score_added)); // we want only new scores
			}

			mDay.score = value;
			if (mNewDay) {
				App.getStore().addDay(mDay, ActiveDatabase.STATE_DIRTY);
			} else {
				App.getStore().updateDay(mDay, ActiveDatabase.STATE_DIRTY);
			}
		}

		setResult(RESULT_OK);
		finish();
	}
}