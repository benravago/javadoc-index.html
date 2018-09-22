
HOSTNAME = $(shell hostname)

CA = /C=US/ST=State/O=Org/CN=CA.$(HOSTNAME)
SERVER = /C=US/ST=State/O=Org/CN=$(HOSTNAME)

ADMIN = /C=US/ST=State/O=Org/CN=admin
CLIENT = /C=US/ST=State/O=Org/CN=client/emailAddress=client@mail.net

