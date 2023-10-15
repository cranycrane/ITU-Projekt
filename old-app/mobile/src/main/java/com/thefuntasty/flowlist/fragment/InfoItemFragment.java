package com.thefuntasty.flowlist.fragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.view.SourceSansProLightTextView;
import com.thefuntasty.flowlist.view.SourceSansProRegularTextView;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.Unbinder;

public class InfoItemFragment extends Fragment {

	@BindView(R.id.image)
	ImageView mImage;
	@BindView(R.id.title)
	SourceSansProRegularTextView mTitle;
	@BindView(R.id.text)
	SourceSansProLightTextView mText;
	private Unbinder unbinder;

	public static InfoItemFragment newInstance(int image, String title, String text) {
		InfoItemFragment f = new InfoItemFragment();

		Bundle b = new Bundle();
		b.putString("title", title);
		b.putString("text", text);
		b.putInt("image", image);

		f.setArguments(b);
		return f;
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		View v = inflater.inflate(R.layout.fragment_info_item, container, false);
		unbinder = ButterKnife.bind(this, v);

		return v;
	}

	@Override
	public void onViewCreated(View view, Bundle savedInstanceState) {
		mImage.setImageResource(getArguments().getInt("image"));
		mTitle.setText(getArguments().getString("title"));
		mText.setText(getArguments().getString("text"));
	}

	@Override
	public void onDestroyView() {
		super.onDestroyView();
		unbinder.unbind();
	}
}
