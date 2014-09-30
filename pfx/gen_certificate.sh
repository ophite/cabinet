sudo openssl pkcs12 -in pydev.asnova.com.pfx -nocerts -out key.pem
sudo openssl pkcs12 -in pydev.asnova.com.pfx -clcerts -nokeys -out server.crt
sudo openssl rsa -in key.pem -out server.key
sudo cp server.key /etc/apache2/ssl
sudo cp server.crt /etc/apache2/ssl  
