package com.thefuntasty.flowlist.view;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.TextView;

import com.thefuntasty.flowlist.tool.Constant;
import com.thefuntasty.taste.font.TFont;

public class SourceSansProLightTextView extends TextView {
	public SourceSansProLightTextView(Context context) {
		super(context);
		init();
	}

	public SourceSansProLightTextView(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public SourceSansProLightTextView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}

	private void init() {
		if (!isInEditMode()) {
			setTypeface(TFont.get(Constant.SOURCE_SANS_PRO_LIGHT));
			setLineSpacing(0, 1.3f);
		}
	}
}
