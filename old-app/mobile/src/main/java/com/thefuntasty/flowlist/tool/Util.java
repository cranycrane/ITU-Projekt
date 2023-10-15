package com.thefuntasty.flowlist.tool;

import android.content.res.Resources;
import android.view.animation.Interpolator;

public class Util {
	private Util() {
	}

	public static boolean equals(String object1, String object2) {
		if (object1 == object2) { // comparing pointers! do not change
			return true;
		}

		return !((object1 == null) || (object2 == null)) && object1.equals(object2);
	}

	public static boolean equals(Integer object1, Integer object2) {
		if (object1 == object2) { // comparing pointers! do not change
			return true;
		}

		return !((object1 == null) || (object2 == null)) && object1.equals(object2);
	}

	public static int dpToPx(Resources r, float dp) {
		final float scale = r.getDisplayMetrics().density;
		return (int) (dp * scale * 0.5f);
	}

	public static Interpolator getReverseInterpolator() {
		return new Interpolator() {
			@Override
			public float getInterpolation(float input) {
				return 1f - input;
			}
		};
	}
}
