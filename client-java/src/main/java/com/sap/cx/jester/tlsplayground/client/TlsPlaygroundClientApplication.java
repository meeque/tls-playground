package com.sap.cx.jester.tlsplayground.client;

import java.io.InputStream;
import java.util.List;

import org.apache.commons.io.IOUtils;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClients;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TlsPlaygroundClientApplication implements ApplicationRunner {

	public static void main(String[] args) {
		SpringApplication.run(TlsPlaygroundClientApplication.class, args);
	}

	@Override
	public void run(ApplicationArguments args) throws Exception {
		final List<String> nonOptionArgs = args.getNonOptionArgs();
		if (nonOptionArgs.size() == 1) {
			final String requestUrl = nonOptionArgs.get(0);

			final HttpClient client = HttpClients.createDefault();

			final HttpResponse response = client.execute(new HttpGet(requestUrl));
			final InputStream responseEntityContentStream = response.getEntity().getContent();
			IOUtils.copy(responseEntityContentStream, System.out);
		}
	}

}