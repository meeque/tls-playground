package com.sap.cx.jester.tlsplayground.client;

import javax.net.ssl.SSLHandshakeException;

import org.junit.Assert;
import org.junit.Test;
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
			Assert.assertTrue(
					"Expected SpringApplication to throw an IllegalStateException, but got " + e.getClass().getName() + " instead.",
					e instanceof IllegalStateException);
			Assert.assertNotNull(
					"Expected SpringApplication to throw an Exception with a cause, but got no cause.",
					cause);
			Assert.assertTrue(
					"Expected SpringApplication to throw an Exception caused by " + expectedExceptionCause.getName() + ", but got " + cause.getClass().getName() + " instead.",
					expectedExceptionCause.isInstance(cause));
			return;
		}
		Assert.fail("Expected exception to be thrown, but got none.");
	}
}
