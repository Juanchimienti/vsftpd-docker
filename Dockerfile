############################################################
# Dockerfile to build a simple vsFTPd server for the eBioKit
# Based on alpine linux
# Version 0.1 October 2017
############################################################

FROM alpine:3.9

# File Author / Maintainer
MAINTAINER Rafael Hernandez <https://github.com/fikipollo>

RUN apk update && apk upgrade &&  apk --update --no-cache add vsftpd

COPY configs/entrypoint.sh /usr/sbin/

CMD /usr/sbin/entrypoint.sh
