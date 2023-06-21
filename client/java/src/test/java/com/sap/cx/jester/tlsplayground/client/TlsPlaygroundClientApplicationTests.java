package com.sap.cx.jester.tlsplayground.client;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.fail;

import javax.net.ssl.SSLHandshakeException;
import javax.net.ssl.SSLPeerUnverifiedException;

import org.junit.jupiter.api.Test;
import org.springframework.boot.SpringApplication;

public class TlsPlaygroundClientApplicationTests {

	@Test
	public void contextLoads() {
	}

	@Test
	public void testDefaultSslContextWithGoodServerCertificate() {
		runWithArgs("https://badssl.com");
	}

	@Test
	public void testPkixSslContextWithGoodServerCertificate() {
		runWithArgs("--tls.check-revocation=true", "https://badssl.com");
	}

	@Test
	public void testDefaultSslContextWithExpiredServerCertificate() {
		runWithArgs(SSLHandshakeException.class, "https://expired.badssl.com/");
	}

	@Test
	public void testPkixSslContextWithExpiredServerCertificate() {
		runWithArgs(SSLHandshakeException.class, "--tls.check-revocation=true", "https://expired.badssl.com/");
	}

	@Test
	public void testDefaultSslContextWithWrongHostServerCertificate() {
		runWithArgs(SSLPeerUnverifiedException.class, "https://wrong.host.badssl.com/");
	}

	@Test
	public void testPkixSslContextWithWrongHostServerCertificate() {
		runWithArgs(SSLPeerUnverifiedException.class, "--tls.check-revocation=true", "https://wrong.host.badssl.com/");
	}

	@Test
	public void testDefaultSslContextWithUntrustedServerCertificate() {
		runWithArgs(SSLHandshakeException.class, "https://untrusted-root.badssl.com/");
	}

	@Test
	public void testPkixSslContextWithUntrustedServerCertificate() {
		runWithArgs(SSLHandshakeException.class, "--tls.check-revocation=true", "https://untrusted-root.badssl.com/");
	}

	@Test
	public void testDefaultSslContextWithRevokedServerCertificate() {
		runWithArgs("https://revoked.badssl.com");
	}

	@Test
	public void testPkixSslContextWithRevokedServerCertificate() {
		runWithArgs(SSLHandshakeException.class, "--tls.check-revocation=true", "https://revoked.badssl.com");
	}

	private void runWithArgs(final String ... args) {
		SpringApplication.run(TlsPlaygroundClientApplication.class, args);
	}

	private void runWithArgs(final Class<?> expectedExceptionCause, final String ... args) {
		try {
			runWithArgs(args);
		} catch (final Exception e) {
			final Throwable cause = e.getCause();
			assertTrue(
					e instanceof IllegalStateException,
					"Expected SpringApplication to throw an IllegalStateException, but got " + e.getClass().getName() + " instead.");
			assertNotNull(
					cause,
					"Expected SpringApplication to throw an Exception with a cause, but got no cause.");
			assertTrue(
					expectedExceptionCause.isInstance(cause),
					"Expected SpringApplication to throw an Exception caused by " + expectedExceptionCause.getName() + ", but got " + cause.getClass().getName() + " instead.");
			return;
		}
		fail("Expected exception to be thrown, but got none.");
	}
}
