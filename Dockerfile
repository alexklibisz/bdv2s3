FROM alpine:3.22.2
RUN apk update
RUN apk add --no-cache aws-cli curl docker gnupg tar
COPY backup.sh /backup.sh
COPY boot.sh /boot.sh
COPY checkenv.sh /checkenv.sh
ENTRYPOINT ["/bin/sh"]
CMD ["/boot.sh"]
