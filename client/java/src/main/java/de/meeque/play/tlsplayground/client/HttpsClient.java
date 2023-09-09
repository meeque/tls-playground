package de.meeque.play.tlsplayground.client;

import java.io.InputStream;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.SSLContext;

import org.apache.commons.io.IOUtils;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClients;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class HttpsClient {

	private final HttpClient httpClient;

	public HttpsClient(@Autowired final SSLContext sslContext) {
		httpClient = HttpClients
				.custom()
				.setConnectionTimeToLive(30, TimeUnit.SECONDS)
				.setSSLContext(sslContext)
				.build();
	}

	public void request(final String url) throws Exception {
		final HttpResponse response = httpClient.execute(new HttpGet(url));
		final InputStream responseEntityContentStream = response.getEntity().getContent();
		IOUtils.copy(responseEntityContentStream, System.out);
	}
}
