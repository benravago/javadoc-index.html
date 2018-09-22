
include ./Make.inc

all: ca server admin client

ca: ca.pem ca.key
server: ca server.pem server.key
admin: ca admin.pem admin.key
client: ca client.pem client.key

#
# Generate a CA certificate/key pair
#
ca.pem ca.key:
	openssl req \
		-new -x509 \
		-subj "$(CA)" \
		-out ca.pem \
		-keyout ca.key -passout pass:changeit

#ln -s ca.pem server-ca.crt
#cp -v ca.pem crt/client-ca.crt
#make -C crt

#
# Generate server certificate/key pair
#
server.pem server.key:
	openssl genrsa \
		-out server.key \
		1024
	openssl req \
		-new \
		-subj "$(SERVER)" \
		-key server.key \
		-out server.req
	openssl x509 \
		-req \
		-in server.req \
		-CA ca.pem \
		-CAkey ca.key -passin pass:changeit \
		-set_serial $(shell date +%s) \
		-out server.pem
	openssl x509 \
		-fingerprint -sha1 \
		-in server.pem \
		-noout \
		| cut -d'=' -f2 \
		| tr -d ':' \
		| tr '[:upper:]' '[:lower:]' \
		> server.pem-sha1

#
# Generate admin user certificate/key pair
#
admin.pem admin.key:
	openssl genrsa \
		-out admin.key \
		1024
	openssl req \
		-new \
		-subj "$(ADMIN)" \
		-key admin.key \
		-out admin.req 
	openssl x509 \
		-req \
		-in admin.req \
		-CA ca.pem \
		-CAkey ca.key -passin pass:changeit \
		-set_serial $(shell date +%s) \
		-out admin.pem
	openssl pkcs12 \
		-export \
		-certfile ca.pem \
		-in admin.pem \
		-inkey admin.key \
		-out admin.p12 -passout pass:changeit

#
# Generate standard user certificate/key pair
#
client.pem client.key: 
	openssl genrsa \
		-out client.key \
		1024
	openssl req \
		-new \
		-subj "$(CLIENT)" \
		-key client.key \
		-out client.req 
	openssl x509 \
		-req \
		-in client.req \
		-CA ca.pem \
		-CAkey ca.key -passin pass:changeit \
		-set_serial $(shell date +%s) \
		-out client.pem
	openssl pkcs12 \
		-export \
		-certfile ca.pem \
		-in client.pem \
		-inkey client.key \
		-out client.p12 -passout pass:changeit
	openssl x509 \
		-text \
		-in client.pem 

#
# additional setup for apache httpd
#
httpd:
	ln -s ca.pem server-ca.crt
	ln -s server.pem server.crt
	cp -v ca.pem crt/client-ca.crt
	make -C crt

clean:
	rm -f ca.* server.* admin.* client.* 
	rm -f server-ca.crt
	rm -f crt/*.0 crt/*.crt

