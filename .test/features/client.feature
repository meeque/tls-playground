Feature: client
  Use TP Demo Clients



Scenario Outline: curl GET request to server `<server>` at `https://<domain>:<port>/<path>`

  Given TP demo server `nginx-simple` is running with self-signed certificates
  When I run `tp client curl --demo-server <server> --domain <domain> --port <port> <path>`
  Then the command should succeed
  And TP should run command `curl --cacert './server/<server>/tls/server.cert.pem' 'https://<domain>:<port>/<path>'`
  And a sub-command should print "<content>"

  Examples:
    | server       | domain                   | port | path             | content                                   |
    | nginx-simple | tls-playground.localhost | 8443 |                  | TLS Playground - Simple Nginx Demo Server |
    | nginx-simple | tls-playground.localhost | 8443 | nothing/here     | 404 Not Found                             |
