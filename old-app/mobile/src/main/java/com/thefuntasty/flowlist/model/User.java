package com.thefuntasty.flowlist.model;

import com.google.gson.annotations.Expose;

public class User {
	@Expose
	public String userId;
	@Expose
	public String name;
	@Expose
	public String email;
	@Expose
	public String dateOfRegister;
	@Expose
	public String userImageUrl = "";

	public String getUserImageUrl() {
		return userImageUrl + "?width=120&height=120";
	}
}
