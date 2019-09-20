package com.sap.cx.jester.tlsplayground.client.tls;

import java.io.File;
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
import javax.net.ssl.TrustManager;
import javax.net.ssl.TrustManagerFactory;

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

	private TrustManager[] createTrustManagers() throws Exception {
		if (tlsProps.getTrustedCerts().isEmpty()) {
			return null;
		}

		final CertificateFactory certFactory = CertificateFactory.getInstance("X.509");
		final KeyStore trustStore = KeyStore.getInstance(KeyStore.getDefaultType());
		trustStore.load(null);

		for (final File certsFile : tlsProps.getTrustedCerts()) {
			final InputStream certsStream = new FileInputStream(certsFile);
			final Collection<X509Certificate> certs = (Collection)certFactory.generateCertificates(certsStream);
			
			for (final X509Certificate cert : certs) {
				trustStore.setCertificateEntry(cert.getSubjectX500Principal().getName(), cert);
			}
		}

		final TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
		trustManagerFactory.init(trustStore);
		return trustManagerFactory.getTrustManagers();
	}

	private KeyManager[] createKeyManagers() throws Exception {
		if (tlsProps.getClientCert() == null && tlsProps.getClientKey() == null) {
			return null;
		}
		if (tlsProps.getClientCert() == null || tlsProps.getClientKey() == null) {
			throw new IllegalStateException("Both of tls.client-cert and tls.client-key must be specified, if either is specified!");
		}

		final CertificateFactory certFactory = CertificateFactory.getInstance("X.509");
		final InputStream certStream = new FileInputStream(tlsProps.getClientCert());
		final Collection<X509Certificate> certs = (Collection)certFactory.generateCertificates(certStream);
		final X509Certificate cert = certs.stream().findFirst().orElseThrow();
		final String certDN = cert.getSubjectX500Principal().getName();

		final KeyFactory keyFactory = KeyFactory.getInstance("RSA");
		final KeySpec keySpec;
		try (final InputStream keyStream = new FileInputStream(tlsProps.getClientKey())) {
			keySpec = new PKCS8EncodedKeySpec(keyStream.readAllBytes());
		}
		final PrivateKey key = keyFactory.generatePrivate(keySpec);

		final KeyStore keyStore = KeyStore.getInstance(KeyStore.getDefaultType());
		keyStore.load(null);
		keyStore.setCertificateEntry(certDN, cert);
		keyStore.setKeyEntry(
				certDN,
				key,
				new char[0],
				certs.toArray(new Certificate[certs.size()]));

		final KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
		keyManagerFactory.init(keyStore, new char[0]);
		return keyManagerFactory.getKeyManagers();
	}

}
