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

import javax.net.ssl.KeyManagerFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import lombok.RequiredArgsConstructor;

@Configuration
@RequiredArgsConstructor
public class LoadCertFilesKeyManagerFactoryConfig {

	@Autowired
	private final TlsProperties tlsProps;
	
	@Bean
	@ConditionalOnProperty(prefix="tls", name={"client-cert", "client-key"})
	public KeyManagerFactory keyManagerFactory() {
		try {
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
			return keyManagerFactory;
		} catch (Exception e) {
			throw new RuntimeException("Failed to create a new KeyManagerFactory.", e);
		}
	};
}
