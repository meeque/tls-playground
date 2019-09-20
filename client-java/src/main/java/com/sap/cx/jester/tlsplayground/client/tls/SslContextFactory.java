package com.sap.cx.jester.tlsplayground.client.tls;

import javax.net.ssl.SSLContext;

public interface SslContextFactory {

	public SSLContext createSslContext() throws Exception;

}
