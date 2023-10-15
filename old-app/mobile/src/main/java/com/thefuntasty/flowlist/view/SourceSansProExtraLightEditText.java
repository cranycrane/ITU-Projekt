package com.thefuntasty.flowlist.view;

import android.content.Context;
import android.support.v7.widget.AppCompatEditText;
import android.util.AttributeSet;
import android.view.inputmethod.EditorInfo;

import com.thefuntasty.flowlist.tool.Constant;
import com.thefuntasty.taste.font.TFont;

public class SourceSansProExtraLightEditText extends AppCompatEditText {
	public SourceSansProExtraLightEditText(Context context) {
		super(context);
		init();
	}

	public SourceSansProExtraLightEditText(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public SourceSansProExtraLightEditText(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}

	private void init() {
		if (!isInEditMode()) {
			setLineSpacing(0f, 1.2f);
			setTypeface(TFont.get(Constant.SOURCE_SANS_PRO_LIGHT));
		}
	}

	@Override
	public void onEditorAction(int actionCode) {
		super.onEditorAction(actionCode);
		if (actionCode == EditorInfo.IME_ACTION_DONE) {
			clearFocus();
		}
	}
}
