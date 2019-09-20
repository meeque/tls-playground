package com.sap.cx.jester.tlsplayground.client.tls;

import java.io.FileInputStream;
import java.io.InputStream;
import java.security.KeyFactory;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.security.spec.KeySpec;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Collection;

import javax.net.ssl.KeyManager;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Component;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class DefaultSslContextFactory implements SslContextFactory {

	@Autowired
	private final TlsProperties tlsProps;

	@Autowired
	@Nullable
	private final TrustManagerFactory trustManagerFactory;

	@Autowired
	@Nullable
	private final KeyManagerFactory keyManagerFactory;

	@Override
	public SSLContext createSslContext() throws Exception {
		final SSLContext context = SSLContext.getInstance(tlsProps.getVersion());
		context.init(
				(keyManagerFactory != null) ? keyManagerFactory.getKeyManagers() : null,
				(trustManagerFactory != null) ? trustManagerFactory.getTrustManagers() : null,
				null
				);
		return context;
	}
}
