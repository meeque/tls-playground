package com.sap.cx.jester.tlsplayground.client.tls;

import javax.net.ssl.KeyManager;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@Service
@EnableConfigurationProperties(TlsProperties.class)
@RequiredArgsConstructor
public class DefaultSslContextFactory implements SslContextFactory {

	@Autowired
	private final TlsProperties tlsProps;

	@Override
	public SSLContext createSslContext() throws Exception {
		final SSLContext context = SSLContext.getInstance(tlsProps.getVersion());
		context.init(createKeyManagers(), createTrustManagers(), null);
		return context;
	}

	private TrustManager[] createTrustManagers() {
		return null;
	}

	private KeyManager[] createKeyManagers() {
		return null;
	}

}
