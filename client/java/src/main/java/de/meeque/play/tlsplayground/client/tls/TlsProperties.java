package de.meeque.play.tlsplayground.client.tls;

import java.io.File;
import java.util.List;
import java.util.Set;

import javax.validation.Valid;
import javax.validation.constraints.NotNull;

import java.security.cert.PKIXRevocationChecker;

import org.springframework.boot.context.properties.ConfigurationProperties;

import lombok.Data;

@ConfigurationProperties(prefix="tls")
@Data
public class TlsProperties {

	@Valid
	@NotNull
	private String version;

	@Valid
	@NotNull
	private List<File> trustedCerts;

	private boolean checkRevocation;

	private Set<PKIXRevocationChecker.Option> pkixRevocationCheckerOptions;

	private File clientCert;

	private File clientKey;
}
