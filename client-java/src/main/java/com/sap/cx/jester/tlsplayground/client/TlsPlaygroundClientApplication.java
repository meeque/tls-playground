package com.sap.cx.jester.tlsplayground.client;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TlsPlaygroundClientApplication implements ApplicationRunner {

	public static void main(String[] args) {
		SpringApplication.run(TlsPlaygroundClientApplication.class, args);
	}

	@Override
	public void run(ApplicationArguments args) throws Exception {
		System.out.println("Hello World!");
	}

}
