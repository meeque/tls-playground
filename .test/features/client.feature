Feature: client
  Use TP Demo Clients



Scenario Outline: curl GET request to `<url>` on nginx-simple with self-signed certificates

  Given TP demo server `nginx-simple` is running with self-signed certificates
  When I run `tp client curl <url>`
  Then the command should succeed
  And TP should run command `curl --cacert './server/nginx-simple/tls/server.cert.pem' '<url>'`
  And a sub-command should print "<content>"

  Examples:
    | url                                                | content                                   |
    | https://tls-playground.localhost:8443/             | TLS Playground - Simple Nginx Demo Server |
    | https://tls-playground.localhost:8443/nothing/here | 404 Not Found                             |



Scenario Outline: curl GET request to `<url>` on nginx-simple with certificates from CA `<ca>`

  Given TP demo server `nginx-simple` is running with certificates from TP demo CA `<ca>`
  When I run `tp client curl <url>`
  Then the command should succeed
  And TP should run command `curl --cacert './ca/<ca>/ca-root.cert.pem' '<url>'`
  And a sub-command should print "<content>"

  Examples:
    | ca         | url                                                | content                                   |
    | ca4servers | https://tls-playground.localhost:8443/             | TLS Playground - Simple Nginx Demo Server |
    | ca4servers | https://tls-playground.localhost:8443/nothing/here | 404 Not Found                             |
