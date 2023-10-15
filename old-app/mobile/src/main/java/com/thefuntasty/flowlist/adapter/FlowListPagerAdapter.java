package com.thefuntasty.flowlist.adapter;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.fragment.FlowListFragment;
import com.thefuntasty.flowlist.fragment.FlowListItemFragment;
import com.thefuntasty.flowlist.model.FlowListItem;
import com.thefuntasty.flowlist.slidingtab.SlidingTabLayout;

import java.util.ArrayList;

public class FlowListPagerAdapter extends FragmentStatePagerAdapter {

	private final SlidingTabLayout mSlidingTabLayout;
	private final ArrayList<FlowListItemFragment> mPagerFragments;
	private final ViewPager mPager;
	private final FlowListFragment mParent;
	public boolean mRightLimitReached = false;
	public boolean mLeftLimitReached = false;
	public boolean mPositionChanged = false;

	public FlowListPagerAdapter(FragmentManager fm, ViewPager viewPager, SlidingTabLayout slidingTabLayout, FlowListFragment parent) {
		super(fm);
		mSlidingTabLayout = slidingTabLayout;
		mPager = viewPager;
		mParent = parent;
		mPagerFragments = new ArrayList<>(); // first - pos 0 fragment
		mRightLimitReached = false;
		mLeftLimitReached = false;
	}

	@Override
	public Fragment getItem(int pos) {
		FlowListItemFragment f = mPagerFragments.get(pos);
		f.setData(App.getStore().getFlowListItem(pos, mParent.defaultPage));
		f.setPosition(pos);
		return f;
	}

	@Override
	public int getCount() {
		return mPagerFragments.size();
	}

	@Override
	public int getItemPosition(Object object) {
		FlowListItemFragment f = ((FlowListItemFragment) object);
		f.setData(App.getStore().getFlowListItem(f.getPosition(), mParent.defaultPage));

		if (mPositionChanged) {
			return POSITION_NONE;
		} else {
			return POSITION_UNCHANGED;
		}
	}

	@Override
	public void notifyDataSetChanged() {
		super.notifyDataSetChanged();
		mSlidingTabLayout.notifyDataSetChanged();
		mPositionChanged = false;
	}

	@Override
	public CharSequence getPageTitle(int position) {
		return App.getStore().getTitle(position, mParent.defaultPage);
	}

	public void moveToRight(int offset) {
		mPager.setCurrentItem(mPager.getCurrentItem() + offset, false);
	}

	public int addFragmentLeft() {
		FlowListItem item = App.getStore().getFlowListItem(-1, mParent.defaultPage);
		if (item == null) {
			mLeftLimitReached = true;
			return 0; // no data
		}

		FlowListItemFragment df = new FlowListItemFragment();
		mPagerFragments.add(0, df);

		mParent.defaultPage++;
		mPositionChanged = true;

		return 1; // fragment added
	}

	public int addFragmentRight() {
		FlowListItem item = App.getStore().getFlowListItem(mPagerFragments.size(), mParent.defaultPage);
		if (item == null) {
			mRightLimitReached = true;
			return 0; // no data
		}

		FlowListItemFragment df = new FlowListItemFragment();
		mPagerFragments.add(mPagerFragments.size(), df);

		return 1; // fragment added
	}
}
