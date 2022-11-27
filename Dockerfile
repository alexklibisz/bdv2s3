# FROM python:alpine3.16
# RUN python3 -m pip install requests==2.28.1
# RUN python3 -m pip install boto3==1.26.16
# RUN tar --version
# COPY bdv2s3.py /bdv2s3.py
# CMD ["python", "-u", "/bdv2s3.py"]

FROM alpine:3.17.0
RUN apk update
RUN apk add --no-cache aws-cli curl tar
COPY bdv2s3.sh /bdv2s3.sh
CMD ["/bin/sh", "/bdv2s3.sh"]
