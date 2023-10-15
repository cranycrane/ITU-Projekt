package com.thefuntasty.flowlist.api;

import com.squareup.okhttp.Interceptor;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.Protocol;
import com.squareup.okhttp.Response;
import com.squareup.okhttp.ResponseBody;

import java.io.IOException;
import java.net.ProtocolException;

/**
 * Workaround as dirty hack, for fix HTTP 204 had non-zero Content-Length: 4.
 * Because server return HTTP 204 with non-null body.
 */
public class RequestTokenInterceptor implements Interceptor {
	@Override
	public Response intercept(Interceptor.Chain chain) throws IOException {
		Response response;
		try {
			response = chain.proceed(chain.request());
		} catch (ProtocolException e) {
			if (e.getMessage().equals("HTTP 204 had non-zero Content-Length: 4")) {
				response = new Response.Builder()
						.request(chain.request())
						.code(204)
						.protocol(Protocol.HTTP_1_1)
						.body(ResponseBody.create(MediaType.parse("application/json"), ""))
						.message("")
						.build();
			} else {
				throw e;
			}
		}
		return response;
	}
}