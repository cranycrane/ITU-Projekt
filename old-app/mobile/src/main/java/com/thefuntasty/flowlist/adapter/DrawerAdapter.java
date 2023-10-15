package com.thefuntasty.flowlist.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.model.Login;

public class DrawerAdapter extends BaseAdapter {

	private final LayoutInflater mInflater;
	private final String[] mRows;

	public DrawerAdapter(Context context, String[] rows) {
		mInflater = LayoutInflater.from(context);
		mRows = rows;
	}

	@Override
	public int getCount() {
		return mRows.length;
	}

	@Override
	public Object getItem(int position) {
		return mRows[position];
	}

	@Override
	public long getItemId(int position) {
		return 0;
	}

	@SuppressLint("ViewHolder")
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		TextView tv = (TextView) mInflater.inflate(R.layout.drawer_list_item, parent, false);
		String text = (String) getItem(position);

		if (text.equals("PŘIHLÁSIT SE")) {
			if (Login.getUserId() != Login.USER_INVALID) {
				text = "ODHLÁSIT SE";
			}
		}
		tv.setText(text);
		return tv;
	}
}
