package com.thefuntasty.flowlist.adapter;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.fragment.InfoItemFragment;

public class InfoAdapter extends FragmentStatePagerAdapter {

	private final int[] mImages;
	private final String[] mTexts;
	private final String[] mTitles;

	public InfoAdapter(FragmentManager fm) {
		super(fm);
		mImages = new int[]{R.drawable.ic_spokojenost, R.drawable.ic_trening, R.drawable.ic_21};
		mTexts = App.getContext().getResources().getStringArray(R.array.info_texts);
		mTitles = App.getContext().getResources().getStringArray(R.array.info_titles);
	}

	@Override
	public Fragment getItem(int position) {
		return InfoItemFragment.newInstance(mImages[position], mTitles[position], mTexts[position]);
	}

	@Override
	public int getCount() {
		return mImages.length;
	}
}
