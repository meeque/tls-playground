package com.sap.cx.jester.tlsplayground.client;

import java.io.InputStream;
import java.util.List;
import java.util.concurrent.TimeUnit;

import org.apache.commons.io.IOUtils;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClients;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

import com.sap.cx.jester.tlsplayground.client.tls.SslContextFactory;
import com.sap.cx.jester.tlsplayground.client.tls.TlsProperties;

@SpringBootApplication
@EnableConfigurationProperties(TlsProperties.class)
public class TlsPlaygroundClientApplication implements ApplicationRunner {

	@Autowired
	private SslContextFactory sslContextFactory;

	public static void main(String[] args) {
		SpringApplication.run(TlsPlaygroundClientApplication.class, args);
	}

	@Override
	public void run(ApplicationArguments args) throws Exception {

		final HttpClient client = HttpClients
				.custom()
				.setConnectionTimeToLive(30, TimeUnit.SECONDS)
				.setSSLContext(sslContextFactory.createSslContext())
				.build();

		final List<String> nonOptionArgs = args.getNonOptionArgs();
		if (nonOptionArgs.isEmpty()) {
			System.out.println("No request target given. Doing nothing. Try specifiying one as an argument!");
			return;
		}

		for (final String requestUrl : nonOptionArgs) {
			final HttpResponse response = client.execute(new HttpGet(requestUrl));
			final InputStream responseEntityContentStream = response.getEntity().getContent();
			IOUtils.copy(responseEntityContentStream, System.out);
		}
	}

}
