package com.sap.cx.jester.tlsplayground.client.tls;

import org.springframework.boot.context.properties.ConfigurationProperties;

import lombok.Data;

@ConfigurationProperties(prefix="tls")
@Data
public class TlsProperties {

	private String version;
}
