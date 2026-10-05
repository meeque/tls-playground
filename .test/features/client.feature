Feature: client
  Use TP Demo Clients



Scenario Outline: curl GET request to server `<server>` at `https://<domain>:<port>/<path>` with self-signed certificates

  Given TP demo server `<server>` is running with self-signed certificates
  When I run `tp client curl --demo-server <server> --domain <domain> --port <port> <path>`
  Then the command should succeed
  And TP should run command `curl --cacert './server/<server>/tls/server.cert.pem' 'https://<domain>:<port>/<path>'`
  And a sub-command should print "<content>"

  Examples:
    | server       | domain                   | port | path             | content                                   |
    | nginx-simple | tls-playground.localhost | 8443 |                  | TLS Playground - Simple Nginx Demo Server |
    | nginx-simple | tls-playground.localhost | 8443 | nothing/here     | 404 Not Found                             |



Scenario Outline: curl GET request to server `<server>` at `https://<domain>:<port>/<path>` with certificates from CA `<ca>`

  Given TP demo server `<server>` is running with certificates from TP demo CA `<ca>`
  When I run `tp client curl --ca=<ca> --demo-server <server> --domain <domain> --port <port> <path>`
  Then the command should succeed
  And TP should run command `curl --cacert './ca/<ca>/ca-root.cert.pem' 'https://<domain>:<port>/<path>'`
  And a sub-command should print "<content>"

  Examples:
    | ca         | server       | domain                   | port | path             | content                                   |
    | ca4servers | nginx-simple | tls-playground.localhost | 8443 |                  | TLS Playground - Simple Nginx Demo Server |
    | ca4servers | nginx-simple | tls-playground.localhost | 8443 | nothing/here     | 404 Not Found                             |
