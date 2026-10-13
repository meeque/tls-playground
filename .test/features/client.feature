Feature: client
  Use TP Demo Clients



Scenario Outline: curl GET request to `<url>` on `<server>` with self-signed certificates

  Given TP demo server `<server>` is running with self-signed certificates
  When I run `tp client curl <url>`
  Then the command should succeed
  And TP should run command `curl --cacert '<cert>' '<url>'`
  And a sub-command should print "<content>"

  Examples:
    | server        | cert                                                   | url                                                       | content                                                       |
    | nginx-simple  | ./server/nginx-simple/tls/server.cert.pem              | https://tls-playground.localhost:8443/                    | TLS Playground - Simple Nginx Demo Server                     |
    | nginx-simple  | ./server/nginx-simple/tls/server.cert.pem              | https://tls-playground.localhost:8443/nothing/here        | 404 Not Found                                                 |
    | nginx-complex | ./server/nginx-complex/virtual/host1/tls/host.cert.pem | https://host1.tls-playground.localhost:8443/              | TLS Playground - Complex Nginx Demo Server - Virtual Server 1 |
    | nginx-complex | ./server/nginx-complex/virtual/host1/tls/host.cert.pem | https://host1a.tls-playground.localhost:8443/nothing/here | 404 Not Found                                                 |
    | nginx-complex | ./server/nginx-complex/virtual/host2/tls/host.cert.pem | https://host2.tls-playground.localhost:8443/              | No required SSL certificate was sent                          |



Scenario Outline: curl GET request to `<url>` on `<server>` with certificates from CA `<ca>`

  Given TP demo server `<server>` is running with certificates from TP demo CA `<ca>`
  When I run `tp client curl <url>`
  Then the command should succeed
  And TP should run command `curl --cacert './ca/<ca>/ca-root.cert.pem' '<url>'`
  And a sub-command should print "<content>"

  Examples:
    | server        | ca         | url                                                | content                                                       |
    | nginx-simple  | ca4servers | https://tls-playground.localhost:8443/             | TLS Playground - Simple Nginx Demo Server                     |
    | nginx-simple  | ca4servers | https://tls-playground.localhost:8443/nothing/here | 404 Not Found                                                 |
    | nginx-complex | ca4all     | https://host1.tls-playground.localhost:8443/       | TLS Playground - Complex Nginx Demo Server - Virtual Server 1 |
    | nginx-complex | ca4all     | https://tls-playground.localhost:8443/             | TLS Playground - Complex Nginx Demo Server - Virtual Server 1 |
    | nginx-complex | ca4all     | https://host2.tls-playground.localhost:8443/       | No required SSL certificate was sent                          |
