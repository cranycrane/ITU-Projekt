package com.thefuntasty.flowlist.activity;

import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.squareup.otto.Subscribe;
import com.squareup.picasso.Callback;
import com.squareup.picasso.Picasso;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.adapter.DrawerAdapter;
import com.thefuntasty.flowlist.dialog.InfoDialogFragment;
import com.thefuntasty.flowlist.dialog.LogoutDialog;
import com.thefuntasty.flowlist.event.ChangeFragmentEvent;
import com.thefuntasty.flowlist.event.LoginLostEvent;
import com.thefuntasty.flowlist.fragment.CalendarFragment;
import com.thefuntasty.flowlist.fragment.FlowListFragment;
import com.thefuntasty.flowlist.fragment.InfoFragment;
import com.thefuntasty.flowlist.model.Login;
import com.thefuntasty.flowlist.tool.DateUtil;
import com.thefuntasty.flowlist.tool.FlowToast;
import com.thefuntasty.flowlist.transformation.CircleTransformation;
import com.thefuntasty.flowlist.view.SourceSansProLightTextViewNoSpacing;
import com.thefuntasty.taste.res.TRes;

import butterknife.BindView;
import butterknife.ButterKnife;

public class BaseDrawerActivity extends AppCompatActivity {

	@BindView(R.id.drawer_list)
	ListView mDrawerList;
	@BindView(R.id.drawer_login_name)
	SourceSansProLightTextViewNoSpacing mLogin;
	@BindView(R.id.drawer_login_image)
	ImageView mImage;
	@BindView(R.id.drawer)
	RelativeLayout mDrawerLogin;
	@BindView(R.id.drawer_layout)
	DrawerLayout mDrawerLayout;

	private ActionBarDrawerToggle mDrawerToggle;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_base_drawer);
		ButterKnife.bind(this);
		initResources();
		initActionBar();
		selectItem(0);
	}

	@Override
	protected void onPostCreate(Bundle savedInstanceState) {
		super.onPostCreate(savedInstanceState);
		mDrawerToggle.syncState();
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		mDrawerToggle.onConfigurationChanged(newConfig);
	}

	@Override
	protected void onStop() {
		super.onStop();
		App.bus().unregister(this);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		mDrawerLayout.removeDrawerListener(mDrawerToggle);
	}

	private void initResources() {
		String[] mDrawerItems = new String[]{"FLOW-LIST", "KALENDÁŘ", "O PRINCIPU FLOW", "WEB", "PŘIHLÁSIT SE"};

		mDrawerList.setAdapter(new DrawerAdapter(this, mDrawerItems));
		mDrawerList.setOnItemClickListener(new DrawerItemClickListener());

		mDrawerToggle = new ActionBarDrawerToggle(
				this,
				mDrawerLayout,
				R.string.drawer_open,
				R.string.drawer_close) {

			public void onDrawerSlide(View drawerView, float slideOffset) {
				super.onDrawerSlide(drawerView, slideOffset);
				if (slideOffset > .55 && !App.mDrawerVisible) {
					onDrawerOpened(drawerView);
					App.mDrawerVisible = true;
				} else if (slideOffset < .45 && App.mDrawerVisible) {
					onDrawerClosed(drawerView);
					App.mDrawerVisible = false;
				}
			}

			@Override
			public void onDrawerOpened(View drawerView) {
				App.mDrawerVisible = true;
				supportInvalidateOptionsMenu();
			}

			@Override
			public void onDrawerClosed(View drawerView) {
				App.mDrawerVisible = false;
				supportInvalidateOptionsMenu();
			}
		};

		mDrawerLayout.addDrawerListener(mDrawerToggle);
	}

	private void initActionBar() {
		ActionBar actionBar = getSupportActionBar();
		if (actionBar != null) {
			actionBar.setTitle("");

			actionBar.setDisplayHomeAsUpEnabled(true);
			actionBar.setHomeButtonEnabled(true);
		}
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		return mDrawerToggle.onOptionsItemSelected(item) || super.onOptionsItemSelected(item);
	}

	@Subscribe
	public void loginLost(LoginLostEvent event) {
		updateUI();
	}

	@Subscribe
	public void onFragmentChange(ChangeFragmentEvent event) {
		selectItem(event.mFragmentID, event.mData);
	}

	protected void selectItem(int position) {
		if (getIntent() != null) {
			selectItem(position, getIntent().getLongExtra(FlowListFragment.DATE_EXTRA, DateUtil.getCal().getTimeInMillis()));
		}
	}

	protected void selectItem(int position, long millis) {
		mDrawerLayout.closeDrawer(mDrawerLogin);
		updateUI();

		FragmentManager fragmentManager = getSupportFragmentManager();
		switch (position) {
			default:
			case 0: // FLOW-LIST
				FlowListFragment f = new FlowListFragment();
				if (getIntent() != null) {
					Bundle bundle = new Bundle();
					bundle.putLong(FlowListFragment.DATE_EXTRA, millis);
					f.setArguments(bundle);
				}

				fragmentManager.beginTransaction().replace(
						R.id.content_frame,
						f,
						FlowListFragment.class.getCanonicalName()).addToBackStack("flow").commit();
				break;
			case 1: // Calendar
				fragmentManager.beginTransaction().replace(
						R.id.content_frame,
						new CalendarFragment(),
						CalendarFragment.class.getCanonicalName()).addToBackStack("calendar").commit();
				break;
			case 2: // About
				fragmentManager.beginTransaction().replace(
						R.id.content_frame,
						new InfoFragment(),
						InfoFragment.class.getCanonicalName()).addToBackStack("about").commit();
				break;
			case 3: // web
				Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://flow-list.cz"));
				startActivity(intent);
				break;
			case 4: // Login
				if (Login.getUserId() == Login.USER_INVALID) {
					mDrawerLayout.closeDrawer(mDrawerLogin);
					Intent i = new Intent(BaseDrawerActivity.this, LoginActivity.class);
					i.putExtra("skip", false);
					startActivity(i);
				} else {
					LogoutDialog.show(this, new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int which) {
							Login.removeUserLogin();
							FlowToast.showToast(TRes.string(R.string.user_succesfully_logged_out), Toast.LENGTH_SHORT);
							updateUI();
						}
					});
				}
				break;
		}
		supportInvalidateOptionsMenu();
	}

	private void updateUI() {
		if (Login.getUserId() == Login.USER_INVALID) {
			mLogin.setVisibility(View.GONE);
			mImage.setVisibility(View.GONE);
		} else {
			mLogin.setVisibility(View.VISIBLE);
			mLogin.setText(Login.getUserName());
			if (!Login.getUserImage().isEmpty()) {
				Picasso.with(this)
						.load(Login.getUserImage())
						.transform(new CircleTransformation())
						.into(mImage, new Callback() {
							@Override
							public void onSuccess() {
								mImage.setVisibility(View.VISIBLE);
							}

							@Override
							public void onError() {

							}
						});
			}

		}
		((DrawerAdapter) mDrawerList.getAdapter()).notifyDataSetChanged();
		mDrawerList.setItemChecked(App.mDrawerPosition, true);
	}

	@Override
	public void onBackPressed() {
		if (getSupportFragmentManager().getBackStackEntryCount() > 1) {
			super.onBackPressed();
		} else {
			finish();
		}
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent); // replace old intent data with new one
	}

	@Override
	protected void onResume() {
		super.onResume();
		updateUI();
		SharedPreferences sh = getSharedPreferences(TRes.string(R.string.preferences), MODE_PRIVATE);

		if (sh.getBoolean("showInfo", true)) {
			DialogFragment d = InfoDialogFragment.newInstance(R.layout.dialog_info_help);
			d.show(getSupportFragmentManager(), "dialog");
			sh.edit().putBoolean("showInfo", false).apply();
		}
	}

	@Override
	protected void onStart() {
		super.onStart();
		App.bus().register(this);
	}
	private class DrawerItemClickListener implements ListView.OnItemClickListener {
		@Override
		public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
			if (position != 3 && position != 4) {
				App.mDrawerPosition = position;
			}
			selectItem(position);
		}
	}
}

