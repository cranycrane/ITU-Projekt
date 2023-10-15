package com.thefuntasty.flowlist.model;

import com.google.gson.annotations.Expose;

public class ErrorResponse {
	@Expose
	public int code;
	@Expose
	public String status;
	@Expose
	public String message;
}
