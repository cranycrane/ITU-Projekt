package com.thefuntasty.flowlist.activity;

import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v7.app.AppCompatActivity;
import android.view.MenuItem;

import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.fragment.FlowListFragment;
import com.thefuntasty.flowlist.tool.FlowGoogleAnalytics;
import com.thefuntasty.taste.res.TRes;

import butterknife.ButterKnife;

public class FillMissingActivity extends AppCompatActivity {
	public static final int FILL_MISSING_REQUEST = 50;
	private static final String SCREEN_NAME = TRes.string(R.string.screen_fill_missing);

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_fill_missing);
		ButterKnife.bind(this);
		FlowGoogleAnalytics.screen(SCREEN_NAME);
		initActionBar();

		Bundle extras = getIntent().getExtras();
		extras.putBoolean("refreshEnabled", false);

		FragmentManager fragmentManager = getSupportFragmentManager();
		FlowListFragment f = new FlowListFragment();
		f.setArguments(extras);

		fragmentManager.beginTransaction().replace(
				R.id.fill_missing_root,
				f,
				FlowListFragment.class.getCanonicalName()).commit();
	}

	private void initActionBar() {
		getSupportActionBar().setDisplayHomeAsUpEnabled(true);
		getSupportActionBar().setHomeButtonEnabled(true);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == android.R.id.home) {
			setResult(RESULT_OK);
			onFinish();
			return true;
		} else {
			return super.onOptionsItemSelected(item);
		}
	}

	@Override
	public void onBackPressed() {
		onFinish();
	}

	private void onFinish() {
		setResult(RESULT_OK);
		finish();
	}
}
