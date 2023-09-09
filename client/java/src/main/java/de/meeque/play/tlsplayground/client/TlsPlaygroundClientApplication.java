package de.meeque.play.tlsplayground.client;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

import de.meeque.play.tlsplayground.client.tls.TlsProperties;

@SpringBootApplication
@EnableConfigurationProperties(TlsProperties.class)
public class TlsPlaygroundClientApplication implements ApplicationRunner {

	@Autowired
	private HttpsClient httpsClient;

	public static void main(String[] args) {
		SpringApplication.run(TlsPlaygroundClientApplication.class, args);
	}

	@Override
	public void run(ApplicationArguments args) throws Exception {

		final List<String> nonOptionArgs = args.getNonOptionArgs();
		if (nonOptionArgs.isEmpty()) {
			System.out.println("No request target given. Doing nothing. Try specifiying one as an argument!");
			return;
		}

		for (final String requestUrl : nonOptionArgs) {
			httpsClient.request(requestUrl);
		}
	}

}
