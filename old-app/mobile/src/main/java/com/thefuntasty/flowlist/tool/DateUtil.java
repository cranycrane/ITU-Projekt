package com.thefuntasty.flowlist.tool;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

public class DateUtil {
	private DateUtil() {
	}

	public static String getTimeStamp() {
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		return df.format(Calendar.getInstance().getTime());
	}

	/**
	 * yyyy-MM-dd
	 */
	public static long dateToMillis(String date) {
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		df.setTimeZone(TimeZone.getTimeZone("UTC"));
		try {
			Date myDate = df.parse(date);
			return myDate.getTime();
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return 0;
	}

	/**
	 * yyyy-MM-dd
	 */
	public static String dateToDBString(Date date) {
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		return df.format(date);
	}

	/**
	 * d. M.
	 */
	public static String dateToShortString(Date date) {
		DateFormat df = new SimpleDateFormat("EE d. M.");
		df.setTimeZone(TimeZone.getTimeZone("UTC"));
		String dateStr = df.format(date);
		return dateStr.substring(0, 1).toUpperCase() + dateStr.substring(1).toLowerCase();
	}

	/**
	 * d. MMMMM
	 */
	public static String dateToStandalone(Date date) {
		DateFormat df = new SimpleDateFormat("d. MMMM");
		df.setTimeZone(TimeZone.getTimeZone("UTC"));
		return df.format(date);
	}

	/**
	 * "LLLL yyyy" first letter uppercase
	 */
	public static String getSectionName(Date date) {
		SimpleDateFormat dateFormat = new SimpleDateFormat("LLLL yyyy");
		dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
		String dateString = dateFormat.format(date);
		return dateString.substring(0, 1).toUpperCase() + dateString.substring(1);
	}

	/**
	 * "cc"
	 */
	public static String getDayInWeek(Date date) {
		DateFormat df = new SimpleDateFormat("cc");
		df.setTimeZone(TimeZone.getTimeZone("UTC"));
		return df.format(date).toUpperCase();
	}

	/**
	 * "cc"
	 */
	public static String getDateString(Date date) {
		DateFormat df = new SimpleDateFormat("d");
		df.setTimeZone(TimeZone.getTimeZone("UTC"));
		return df.format(date).toUpperCase();
	}

	@SuppressWarnings("ResourceType")
	public static String millisToString(long millis) {
		Calendar now = Calendar.getInstance();
		now.setTimeInMillis(millis);

		Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		cal.setTimeInMillis(0);
		cal.set(now.get(Calendar.YEAR), now.get(Calendar.MONTH), now.get(Calendar.DAY_OF_MONTH));
		return DateUtil.dateToDBString(cal.getTime());
	}


	@SuppressWarnings("ResourceType")
	public static Calendar getCal() {
		Calendar now = Calendar.getInstance();

		Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		cal.setTimeInMillis(0);
		cal.set(now.get(Calendar.YEAR), now.get(Calendar.MONTH), now.get(Calendar.DAY_OF_MONTH));
		return cal;
	}
}
