package com.thefuntasty.flowlist.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;

import com.thefuntasty.flowlist.tool.Constant;
import com.thefuntasty.taste.font.TFont;

public class KonecProkrastinaceEditText extends EditText {
	public KonecProkrastinaceEditText(Context context) {
		super(context);
		init();
	}

	public KonecProkrastinaceEditText(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public KonecProkrastinaceEditText(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}

	private void init() {
		if (!isInEditMode()) {
			setTypeface(TFont.get(Constant.KONECPROKRASTINACE));
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
