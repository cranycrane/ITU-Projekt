package com.thefuntasty.flowlist.fragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.viewpagerindicator.CirclePageIndicator;

import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.adapter.InfoAdapter;
import com.thefuntasty.flowlist.tool.FlowGoogleAnalytics;
import com.thefuntasty.taste.res.TRes;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.Unbinder;

public class InfoFragment extends Fragment {
	private static final String SCREEN_NAME = TRes.string(R.string.screen_info);
	@BindView(R.id.pager)
	ViewPager mPager;
	@BindView(R.id.indicator)
	CirclePageIndicator mIndicator;
	private Unbinder unbinder;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		View view = inflater.inflate(R.layout.fragment_info, container, false);
		unbinder = ButterKnife.bind(this, view);
		FlowGoogleAnalytics.screen(SCREEN_NAME);
		return view;
	}

	@Override
	public void onViewCreated(View view, Bundle savedInstanceState) {
		mPager.setAdapter(new InfoAdapter(getChildFragmentManager()));
		mIndicator.setViewPager(mPager);
		mIndicator.setRadius(9);
		mIndicator.setStrokeColor(TRes.color(R.color.indicator_fill));
		mIndicator.setFillColor(TRes.color(R.color.indicator_fill));
	}

	@Override
	public void onDestroyView() {
		super.onDestroyView();
		unbinder.unbind();
	}
}
