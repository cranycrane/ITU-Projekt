package com.thefuntasty.flowlist.view;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.AppCompatEditText;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;

import com.thefuntasty.flowlist.tool.Constant;
import com.thefuntasty.taste.font.TFont;

public class MultilineActionDoneLightEditText extends AppCompatEditText {

	OnBackClickedListener mListener;

	public MultilineActionDoneLightEditText(Context context) {
		super(context);
		init();
	}

	public MultilineActionDoneLightEditText(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public MultilineActionDoneLightEditText(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}

	private void init() {
		if (!isInEditMode()) {
			setLineSpacing(0f, 1.2f);
		}
		setTypeface(TFont.get(Constant.SOURCE_SANS_PRO_LIGHT));
	}

	@Override
	public boolean onKeyPreIme(int keyCode, @NonNull KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_UP) {
			if (mListener != null) {
				mListener.onKeyboardBackClicked(this);
			}
			return false;
		}
		return super.dispatchKeyEvent(event);
	}

	@Override
	public InputConnection onCreateInputConnection(@NonNull EditorInfo outAttrs) {
		InputConnection connection = super.onCreateInputConnection(outAttrs);
		int imeActions = outAttrs.imeOptions & EditorInfo.IME_MASK_ACTION;
		if ((imeActions & EditorInfo.IME_ACTION_DONE) != 0) {
			// clear the existing action
			outAttrs.imeOptions ^= imeActions;
			// set the DONE action
			outAttrs.imeOptions |= EditorInfo.IME_ACTION_DONE;
		}
		if ((outAttrs.imeOptions & EditorInfo.IME_FLAG_NO_ENTER_ACTION) != 0) {
			outAttrs.imeOptions &= ~EditorInfo.IME_FLAG_NO_ENTER_ACTION;
		}
		return connection;
	}

	public void setOnBackClickListener(OnBackClickedListener listener) {
		mListener = listener;
	}

	public interface OnBackClickedListener {
		void onKeyboardBackClicked(View view);
	}
}
