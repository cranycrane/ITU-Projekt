package com.thefuntasty.flowlist.activity;

import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.TextView;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.database.ActiveDatabase;
import com.thefuntasty.flowlist.dialog.EraseRecordDialog;
import com.thefuntasty.flowlist.dialog.SaveDialog;
import com.thefuntasty.flowlist.model.FlowDay;
import com.thefuntasty.flowlist.tool.FlowGoogleAnalytics;
import com.thefuntasty.flowlist.tool.Util;
import com.thefuntasty.flowlist.view.MultilineActionDoneLightEditText;
import com.thefuntasty.taste.keyboard.TKeyboard;
import com.thefuntasty.taste.res.TRes;

import butterknife.BindView;
import butterknife.ButterKnife;

public class OneRecordActivity extends AppCompatActivity {
	public static final String DATE_EXTRA = "date";
	public static final String RECORD_ID_EXTRA = "record_id";
	private static final String SCREEN_NAME = TRes.string(R.string.screen_one_record);
	boolean mNewDay = false;

	boolean mStarred;
	long mMillis;
	int mRecordID;
	FlowDay mDay;
	@BindView(R.id.one_record_edittext)
	MultilineActionDoneLightEditText mRecord;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_one_record);
		ButterKnife.bind(this);
		FlowGoogleAnalytics.screen(SCREEN_NAME);

		getSupportActionBar().setDisplayHomeAsUpEnabled(true);

		initListeners();

		Bundle bundle = getIntent().getExtras();
		mMillis = bundle.getLong(DATE_EXTRA);
		mRecordID = bundle.getInt(RECORD_ID_EXTRA);

		mDay = App.getStore().getDay(mMillis);

		if (mDay == null) {
			mDay = new FlowDay(mMillis);
			mNewDay = true;
		}

		mRecord.setText(getText());
		mStarred = isStarred();
		mRecord.requestFocus();
	}

	public void initListeners() {
		mRecord.setOnEditorActionListener(new TextView.OnEditorActionListener() {
			@Override
			public boolean onEditorAction(TextView view, int actionId, KeyEvent event) {
				if (actionId == EditorInfo.IME_ACTION_DONE) {
					TKeyboard.hideSoftKeyboard(OneRecordActivity.this, mRecord);
					save();
					return true;
				}
				return false;
			}
		});

		mRecord.setOnBackClickListener(new MultilineActionDoneLightEditText.OnBackClickedListener() {
			@Override
			public void onKeyboardBackClicked(View view) {

			}
		});
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.one_record_menu, menu);
		return true;
	}

	@Override
	public boolean onPrepareOptionsMenu(Menu menu) {
		if (mStarred) {
			menu.findItem(R.id.menu_item_star).setVisible(false);
			menu.findItem(R.id.menu_item_star_hover).setVisible(true);
			mRecord.setTextColor(TRes.color(R.color.main_red));
		} else {
			menu.findItem(R.id.menu_item_star).setVisible(true);
			menu.findItem(R.id.menu_item_star_hover).setVisible(false);
			mRecord.setTextColor(TRes.color(android.R.color.black));
		}

		if (isEmpty()) {
			menu.findItem(R.id.menu_item_remove).setVisible(false);
		} else {
			menu.findItem(R.id.menu_item_remove).setVisible(true);
		}
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			case android.R.id.home:
				showSaveDialog();
				return true;
			case R.id.menu_item_star_hover:
				mStarred = false;
				supportInvalidateOptionsMenu();
				return true;
			case R.id.menu_item_star:
				mStarred = true;
				supportInvalidateOptionsMenu();
				return true;
			case R.id.menu_item_remove:
				EraseRecordDialog.show(this, new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						delete();
					}
				});
				return true;
			case R.id.action_save:
				save();
				return true;
			default:
				return super.onOptionsItemSelected(item);
		}
	}

	private boolean isStarred() {
		switch (mRecordID) {
			case 1:
				return mDay.star1;
			case 2:
				return mDay.star2;
			case 3:
				return mDay.star3;
			default:
				return false;
		}
	}

	private boolean isEmpty() {
		switch (mRecordID) {
			case 1:
				return TextUtils.isEmpty(mDay.record1);
			case 2:
				return TextUtils.isEmpty(mDay.record2);
			case 3:
				return TextUtils.isEmpty(mDay.record3);
			default:
				return false;
		}
	}

	private String getText() {
		switch (mRecordID) {
			case 1:
				return mDay.record1;
			case 2:
				return mDay.record2;
			case 3:
				return mDay.record3;
			default:
				return "";
		}
	}

	private void setText(String str) {
		switch (mRecordID) {
			case 1:
				mDay.record1 = str;
				break;
			case 2:
				mDay.record2 = str;
				break;
			case 3:
				mDay.record3 = str;
				break;
		}
	}

	private boolean getStar() {
		switch (mRecordID) {
			case 1:
				return mDay.star1;
			case 2:
				return mDay.star2;
			case 3:
				return mDay.star3;
			default:
				return false;
		}
	}

	private void setStar(boolean starred) {
		switch (mRecordID) {
			case 1:
				mDay.star1 = starred;
				break;
			case 2:
				mDay.star2 = starred;
				break;
			case 3:
				mDay.star3 = starred;
				break;
		}
	}

	@Override
	public void onBackPressed() {
		showSaveDialog();
	}

	private void showSaveDialog() {
		if (mStarred == getStar() && mRecord.getText().toString().equals(getText())) { // nothing has changed
			end();
		} else {
			SaveDialog.show(this, new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int which) {
					save();
				}
			}, new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int which) {
					end();
				}
			});
		}
	}

	private void end() {
		setResult(RESULT_CANCELED);
		finish();
	}


	private void save() {
		String text = mRecord.getText().toString();
		if (text.isEmpty()) { // if text is empty, delete record
			delete();
			return;
		}

		if (!Util.equals(text, getText()) || mStarred != getStar()) {
			if ("".equals(getText())) {
				FlowGoogleAnalytics.click(SCREEN_NAME, TRes.string(R.string.click_record_added)); // we want only new records
			}

			setText(text);
			setStar(mStarred);

			if (mNewDay) {
				App.getStore().addDay(mDay, ActiveDatabase.STATE_DIRTY);
			} else {
				App.getStore().updateDay(mDay, ActiveDatabase.STATE_DIRTY);
			}
		}

		setResult(RESULT_OK);
		finish();
	}

	private void delete() {
		setText("");
		setStar(false);

		if (mNewDay) {
			App.getStore().addDay(mDay, ActiveDatabase.STATE_DIRTY);
		} else {
			App.getStore().updateDay(mDay, ActiveDatabase.STATE_DIRTY);
		}

		setResult(RESULT_OK);
		finish();
	}
}
