FROM alpine:3.17.0
RUN apk update
RUN apk add --no-cache aws-cli curl docker tar
COPY backup.sh /backup.sh
COPY boot.sh /boot.sh
COPY checkenv.sh /checkenv.sh
ENTRYPOINT ["/bin/sh"]
CMD ["/boot.sh"]
