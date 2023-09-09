package de.meeque.play.tlsplayground.client.tls;

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
	public TrustManagerFactory trustManagerFactory() throws Exception {

		// TODO support using both JDK trust store and custom list of trusted certificates
		final KeyStore trustStore;
		if (tlsProps.getTrustedCerts() != null && !tlsProps.getTrustedCerts().isEmpty()) {
			trustStore = buildTrustStore();
		} else {
			trustStore = buildDefaultJdkTrustStore();
		}

		final TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());

		if (tlsProps.isCheckRevocation()) {
			final CertPathBuilder certificatePathBuilder = CertPathBuilder.getInstance("PKIX");
			final PKIXRevocationChecker revocationChecker = (PKIXRevocationChecker)certificatePathBuilder.getRevocationChecker();
			if (tlsProps.getPkixRevocationCheckerOptions() != null ) {
				revocationChecker.setOptions(tlsProps.getPkixRevocationCheckerOptions());
			}
			final PKIXBuilderParameters pkixParams = new PKIXBuilderParameters(
					trustStore,
					new X509CertSelector()
					);
			pkixParams.addCertPathChecker(revocationChecker);
			trustManagerFactory.init(new CertPathTrustManagerParameters(pkixParams));
		} else {
			trustManagerFactory.init(trustStore);
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

	private KeyStore buildDefaultJdkTrustStore() throws Exception {
		final char separator = File.separatorChar;
		final String trustStoreFileName = System.getProperty("java.home") + separator + "lib" + separator + "security" + separator + "cacerts";
		final InputStream trustStoreInputStream = new FileInputStream(trustStoreFileName);

		final KeyStore trustStore = KeyStore.getInstance("JKS");
		trustStore.load(trustStoreInputStream, "changeit".toCharArray());
		return trustStore;
	}
}
