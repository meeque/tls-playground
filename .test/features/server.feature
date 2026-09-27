Feature: server
  Manage and use TP Demo Servers



Background:

  Given all TP demo servers have been cleaned
  And all TP CAs have been cleaned



Scenario: When called without arguments, `tp server` should print basic usage info

  When I run `tp server`
  Then the command should fail
  And TP should print "No TP Demo Server command given."
  And TP should print "Try one of the following:"
  And a sub-command should print "init"
  And a sub-command should print "run"
  And a sub-command should print "start"
  And a sub-command should print "reload"
  And a sub-command should print "stop"
  And a sub-command should print "clean"
  And TP should print "Or, run 'tp server --help' to learn more about these commands."



Scenario: `tp server --help` should print help contents

  When I run `tp server --help`
  Then the command should succeed
  And a sub-command should print "Summary:    Control TLS Playground Demo Servers"
  And a sub-command should print "Available Commands:"
  And a sub-command should print "Arguments:"
  And a sub-command should print "Global Options:"
  And a sub-command should print "Environment:"



Scenario Outline: Initialize demo server `<server>` with self-signed certificates and clean up afterwards

  Then nginx config template file `server/<server>/nginx.conf.tmpl` should exist
  But nginx config file `server/<server>/nginx.conf` should NOT exist
  And nginx logs directory `server/<server>/var/logs` should NOT exist

  When I run `tp server init <server>`
  Then the command should succeed
  And TP should print "Initializing demo server '<server>'"
  And TP should print "Creating server certificates for demo server '<server>' using certificate provider 'selfsign'"
  And nginx config file `server/<server>/nginx.conf` should exist
  And nginx logs directory `server/<server>/var/logs` should exist
  # TODO also verify server cert and key

  When I run `tp server clean <server>`
  Then the command should succeed
  And TP should print "Cleaning transient files of demo server '<server>'"
  And nginx config file `server/<server>/nginx.conf` should NOT exist
  And nginx logs directory `server/<server>/var/logs` should NOT exist
  But nginx config template file `server/<server>/nginx.conf.tmpl` should exist

  Examples:
    | server        |
    | nginx-simple  |
    | nginx-complex |



Scenario Outline: Initialize demo server `<server>` with certificates from CA `<ca>` via `<ca_option>`

  # TODO move CA init/teardown to @BeforeAll/@AfterAll and reuse them throughout server tests
  When I run `tp ca init <ca>`
  Then the command should succeed
  And CA root certificate file `ca/<ca>/ca-root.cert.pem` should exist

  When I run `tp server init <ca_option> <server>`
  Then the command should succeed
  And TP should print "Creating server certificates for demo server '<server>' using certificate provider 'ca'"
  And nginx config file `server/<server>/nginx.conf` should exist

  Examples:
    | server        | ca         | ca_option   |
    | nginx-simple  | ca4servers | --ca        |
    | nginx-complex | ca4all     | --ca=ca4all |



Scenario: Initialize all TP demo servers at once

  When I run `tp server init`
  Then the command should succeed
  And TP should print "No demo server name specified. Proceeding to initialize all demo servers..."
  And nginx config file `server/nginx-simple/nginx.conf` should exist
  And nginx config file `server/nginx-complex/nginx.conf` should exist



# TODO merge next two tests?
Scenario: Run init hook when initializing nginx-complex

  When I run `tp server init nginx-complex`
  Then the command should succeed
  And TP should print "Running init hook for server 'nginx-complex'"
  And trusted client CAs file `server/nginx-complex/virtual/host2/tls/trusted-clients-cas.certs.pem` should exist



Scenario: Run clean hook when cleaning nginx-complex

  When I run `tp server init nginx-complex`
  Then the command should succeed
  And trusted client CAs file `server/nginx-complex/virtual/host2/tls/trusted-clients-cas.certs.pem` should exist

  When I run `tp server clean nginx-complex`
  Then the command should succeed
  And TP should print "Running clean hook for server 'nginx-complex'"
  And trusted client CAs file `server/nginx-complex/virtual/host2/tls/trusted-clients-cas.certs.pem` should NOT exist



Scenario Outline: Start, reload, and stop demo server `<server>`

  When I run `tp server init <server>`
  Then the command should succeed

  When I run `tp server start <server>`
  Then the command should succeed
  And TP should print "Starting nginx server"
  And nginx PID file `server/<server>/var/nginx.pid` should exist

  When I run `tp server reload <server>`
  Then the command should succeed
  And TP should print "Reloading configuration"

  When I run `tp server stop <server>`
  Then the command should succeed
  And TP should print "Stopping nginx server"

  Examples:
    | server        |
    | nginx-simple  |
    | nginx-complex |



Scenario: Fail starting a demo server without server name

  When I run `tp server start`
  Then the command should fail
  And TP should print "Failed to start demo server! No demo server name specified!"
  And TP should print "Try one of the following:"
  And a sub-command should print "nginx-simple"
  And a sub-command should print "nginx-complex"



Scenario: Fail starting a non-existent demo server

  When I run `tp server start not-a-server`
  Then the command should fail
  And TP should print "Failed to start demo server 'not-a-server'"
  And TP should print "Try one of the following instead:"
  And a sub-command should print "nginx-simple"
  And a sub-command should print "nginx-complex"
