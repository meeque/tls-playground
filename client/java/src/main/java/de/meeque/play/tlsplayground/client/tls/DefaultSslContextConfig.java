package de.meeque.play.tlsplayground.client.tls;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.lang.Nullable;

import lombok.RequiredArgsConstructor;

@Configuration
@RequiredArgsConstructor
public class DefaultSslContextConfig {

	@Autowired
	private final TlsProperties tlsProps;

	@Autowired
	@Nullable
	private final TrustManagerFactory trustManagerFactory;

	@Autowired
	@Nullable
	private final KeyManagerFactory keyManagerFactory;

	@Bean
	public SSLContext sslContext() throws Exception {
		final SSLContext context = SSLContext.getInstance(tlsProps.getVersion());
		context.init(
				(keyManagerFactory != null) ? keyManagerFactory.getKeyManagers() : null,
				(trustManagerFactory != null) ? trustManagerFactory.getTrustManagers() : null,
				null
				);
		return context;
	}
}
