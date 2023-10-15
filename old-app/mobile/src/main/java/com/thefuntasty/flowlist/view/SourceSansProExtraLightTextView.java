package com.thefuntasty.flowlist.view;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.TextView;

import com.thefuntasty.flowlist.tool.Constant;
import com.thefuntasty.taste.font.TFont;

public class SourceSansProExtraLightTextView extends TextView {
	public SourceSansProExtraLightTextView(Context context) {
		super(context);
		init();
	}

	public SourceSansProExtraLightTextView(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public SourceSansProExtraLightTextView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}

	private void init() {
		if (!isInEditMode()) {
			setTypeface(TFont.get(Constant.SOURCE_SANS_PRO_LIGHT));
		}
	}
}
