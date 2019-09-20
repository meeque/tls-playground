package com.sap.cx.jester.tlsplayground.client.tls;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.security.KeyStore;
import java.security.cert.CertPathBuilder;
import java.security.cert.CertificateFactory;
import java.security.cert.PKIXBuilderParameters;
import java.security.cert.PKIXRevocationChecker;
import java.security.cert.X509CertSelector;
import java.security.cert.X509Certificate;
import java.util.Collection;
import java.util.EnumSet;

import javax.net.ssl.CertPathTrustManagerParameters;
import javax.net.ssl.TrustManagerFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import lombok.RequiredArgsConstructor;

@Configuration
@RequiredArgsConstructor
public class LoadCertFilesTrustManagerFactoryConfig {

	@Autowired
	private final TlsProperties tlsProps;

	@Bean
	@ConditionalOnProperty(prefix="tls", name="trusted-certs")
	public TrustManagerFactory trustManagerFactory() throws Exception {

		final TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());

		if (tlsProps.isCheckRevocation()) {
			final CertPathBuilder certificatePathBuilder = CertPathBuilder.getInstance("PKIX");
			final PKIXRevocationChecker revocationChecker = (PKIXRevocationChecker)certificatePathBuilder.getRevocationChecker();
			revocationChecker.setOptions(
					EnumSet.of(PKIXRevocationChecker.Option.NO_FALLBACK)
					);
			final PKIXBuilderParameters pkixParams = new PKIXBuilderParameters(
					buildTrustStore(),
					new X509CertSelector()
					);
			pkixParams.addCertPathChecker(revocationChecker);
			trustManagerFactory.init(new CertPathTrustManagerParameters(pkixParams));
		} else {
			trustManagerFactory.init(buildTrustStore());
		}

		return trustManagerFactory;
	}

	private KeyStore buildTrustStore() throws Exception {
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
		return trustStore;
	}

}
