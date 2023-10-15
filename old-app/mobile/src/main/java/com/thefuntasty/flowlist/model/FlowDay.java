package com.thefuntasty.flowlist.model;

import android.text.TextUtils;

import com.activeandroid.Model;
import com.activeandroid.annotation.Column;
import com.activeandroid.annotation.Table;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;
import com.google.gson.annotations.Expose;

import com.thefuntasty.flowlist.tool.DateUtil;
import com.thefuntasty.flowlist.tool.Util;

import java.lang.reflect.Type;

@Table(name = "flow_days")
public final class FlowDay extends Model {

	@Expose @Column(name = "day")
	public String day = null;
	@Expose @Column(name = "lastEdit")
	public String lastEdit = null;
	@Expose @Column(name = "score")
	public Integer score = null;
	@Expose @Column(name = "skipped")
	public boolean skipped = false;
	@Expose @Column(name = "record1")
	public String record1 = "";
	@Expose @Column(name = "star1")
	public boolean star1 = false;
	@Expose @Column(name = "record2")
	public String record2 = "";
	@Expose @Column(name = "star2")
	public boolean star2 = false;
	@Expose @Column(name = "record3")
	public String record3 = "";
	@Expose @Column(name = "star3")
	public boolean star3 = false;
	@Expose @Column(name = "state")
	public int state = -1;
	@Expose @Column(name = "version")
	public String version = "";

	public FlowDay() {
		super();
	}

	public FlowDay(long millis) {
		super();
		day = DateUtil.millisToString(millis);
	}

	public static void copyData(FlowDay to, FlowDay from) {
		to.day = from.day;
		to.lastEdit = from.lastEdit;
		to.score = from.score;
		to.record1 = (from.record1 == null) ? "" : from.record1;
		to.star1 = from.star1;
		to.record2 = (from.record2 == null) ? "" : from.record2;
		to.star2 = from.star2;
		to.record3 = (from.record3 == null) ? "" : from.record3;
		to.star3 = from.star3;
		to.skipped = from.skipped;
		to.version = (from.version == null) ? "" : from.version;
	}

	public boolean isStarred() {
		return star1 || star2 || star3;
	}

	public boolean isEmpty() {
		return TextUtils.isEmpty(record1) && TextUtils.isEmpty(record2) && TextUtils.isEmpty(record3);
	}

	@Override
	public boolean equals(Object obj) {
		if (!(obj instanceof FlowDay)) return false;

		FlowDay day = (FlowDay) obj;
		boolean sameContent = true;

		sameContent &= Util.equals(day.day, this.day);
		sameContent &= Util.equals(day.score, this.score);

		sameContent &= Util.equals(day.record1, this.record1);
		sameContent &= Util.equals(day.record2, this.record2);
		sameContent &= Util.equals(day.record3, this.record3);

		sameContent &= (day.star1 == this.star1);
		sameContent &= (day.star2 == this.star2);
		sameContent &= (day.star3 == this.star3);

		sameContent &= Util.equals(day.version, this.version);

		return sameContent;
	}

	public static class FlowDayTypeAdapter implements JsonSerializer<FlowDay> {

		public FlowDayTypeAdapter() {
			super();
		}

		@Override
		public JsonElement serialize(FlowDay day, Type typeOfSrc, JsonSerializationContext context) {
			final JsonObject jsonObj = new JsonObject();
			jsonObj.add("day", context.serialize(day.day));
			jsonObj.add("lastEdit", context.serialize(day.lastEdit));
			jsonObj.add("score", context.serialize(day.score));
			jsonObj.add("record1", context.serialize(day.record1));
			jsonObj.add("star1", context.serialize(day.star1));
			jsonObj.add("record2", context.serialize(day.record2));
			jsonObj.add("star2", context.serialize(day.star2));
			jsonObj.add("record3", context.serialize(day.record3));
			jsonObj.add("star3", context.serialize(day.star3));
			jsonObj.add("skipped", context.serialize(day.skipped));
			jsonObj.add("version", context.serialize(day.version));
			return jsonObj;
		}
	}
}
