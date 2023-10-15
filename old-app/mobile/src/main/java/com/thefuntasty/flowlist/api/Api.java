package com.thefuntasty.flowlist.api;

import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Protocol;

import com.thefuntasty.flowlist.App;
import com.thefuntasty.flowlist.R;
import com.thefuntasty.flowlist.event.LoginLostEvent;
import com.thefuntasty.flowlist.model.ErrorResponse;
import com.thefuntasty.flowlist.model.FlowDay;
import com.thefuntasty.flowlist.model.Login;
import com.thefuntasty.flowlist.model.TokenValidity;
import com.thefuntasty.flowlist.model.User;
import com.thefuntasty.flowlist.tool.FlowToast;
import com.thefuntasty.flowlist.tool.StringTypeAdapter;
import com.thefuntasty.taste.res.TRes;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import retrofit.Callback;
import retrofit.ErrorHandler;
import retrofit.RequestInterceptor;
import retrofit.RestAdapter;
import retrofit.RetrofitError;
import retrofit.client.OkClient;
import retrofit.converter.ConversionException;
import retrofit.converter.GsonConverter;
import retrofit.http.Body;
import retrofit.http.GET;
import retrofit.http.POST;
import retrofit.http.Path;
import retrofit.http.Query;
import retrofit.http.QueryMap;

public class Api {
	private static final String URL = "https://www.flow-list.cz/api/v1";
	private static FlowList mInstance;
	private static GsonConverter mConverter;

	private Api() {
	}

	public static FlowList get() {
		if (mInstance == null) {
			OkHttpClient okHttpClient = new OkHttpClient();
			okHttpClient.setProtocols(Collections.singletonList(Protocol.HTTP_1_1)); //Fix for issues with server side
			okHttpClient.interceptors().add(new RequestTokenInterceptor());

			mInstance = new RestAdapter
					.Builder()
					.setEndpoint(URL)
					.setClient(new OkClient(okHttpClient))
					.setConverter(getConverter())
					.setErrorHandler(new ErrorHandler() {
						@Override
						public Throwable handleError(RetrofitError cause) {
							if (cause.getResponse() != null && cause.getResponse().getStatus() == 401) {
								ErrorResponse response = null;
								try {
									response = (ErrorResponse) new GsonConverter(new Gson()).fromBody(cause.getResponse().getBody(), ErrorResponse.class);
								} catch (ConversionException e) {
									e.printStackTrace();
								}
								if (response != null && response.message != null && response.message.contains("token expired")) {
									new Handler(Looper.getMainLooper()).post(new Runnable() {
										@Override
										public void run() {
											Login.removeUserLogin();
											App.bus().post(new LoginLostEvent());
											FlowToast.showToast(R.string.invalid_token_log_in_again, Toast.LENGTH_LONG);
										}
									});
								}
							}
							return cause;
						}
					})
					.setRequestInterceptor(new RequestInterceptor() {
						@Override
						public void intercept(RequestFacade request) {
							request.addHeader("Accept", "application/json;charset=UTF-8");
						}
					})
					.build()
					.create(FlowList.class);
		}

		return mInstance;
	}

	private static GsonConverter getConverter() {
		if (mConverter == null) {
			GsonBuilder builder = new GsonBuilder();
			builder.registerTypeAdapter(FlowDay.class, new FlowDay.FlowDayTypeAdapter());
			builder.registerTypeAdapter(String.class, new StringTypeAdapter());
			builder.serializeNulls();
			builder.excludeFieldsWithoutExposeAnnotation(); //Fix for retrofit on Android M
			mConverter = new GsonConverter(builder.create());
		}

		return mConverter;
	}

	public static void handleError(RetrofitError retrofitError) {
		if (retrofitError.getKind() == RetrofitError.Kind.NETWORK) {
			FlowToast.showToast(TRes.string(R.string.synchronization_error_network), Toast.LENGTH_LONG);
		} else {
			FlowToast.showToast(TRes.string(R.string.synchronization_error_unknown), Toast.LENGTH_LONG);
		}
	}

	public interface FlowList {

		@GET("/tokenFacebook") void loginFB(
				@Query("facebookId") String facebookID,
				@Query("facebookToken") String facebookToken,
				Callback<Login> response);

		@GET("/tokenPassword") void loginEmail(
				@Query("login") String login,
				@Query("password") String password,
				Callback<Login> response);

		@GET("/tokenValid") void isTokenValid(
				@Query("accessToken") String token,
				Callback<TokenValidity> response);

		@GET("/users/{userId}") void getUserInfo(
				@Path("userId") int userId,
				@Query("accessToken") String token,
				Callback<User> response);

		@POST("/users/{userId}/records") void sendRecords(
				@Path("userId") int userId,
				@Query("accessToken") String token,
				@Query("device") String deviceID,
				@Body List<FlowDay> days,
				Callback<List<FlowDay>> response);

		@POST("/users/{userId}/records/{yyyy-mm-dd}") void sendRecord(
				@Path("userId") int userId,
				@Query("accessToken") String token,
				@Query("device") String deviceID,
				@Path("yyyy-mm-dd") String date,
				@Body FlowDay day,
				Callback<FlowDay> response);

		@GET("/users/{userId}/records/{yyyy-mm-dd}") FlowDay getRecord(
				@Path("userId") int userId,
				@Query("accessToken") String token,
				@Path("yyyy-mm-dd") String date);

		@GET("/users/{userId}/records/{yyyy-mm-dd}") void getRecord(
				@Path("userId") int userId,
				@Query("accessToken") String token,
				@Path("yyyy-mm-dd") String date,
				Callback<FlowDay> response);

		@GET("/users/{userId}/records") void getRecords(
				@Path("userId") int userId,
				@Query("accessToken") String token,
				@QueryMap Map<String, String> query,
				Callback<List<FlowDay>> response);

		@GET("/users/{userId}/records") void getNewerRecords(
				@Path("userId") int userId,
				@Query("accessToken") String token,
				@Query("lastEditAfter") String date,
				Callback<List<FlowDay>> response);
	}
}
