FROM python:alpine3.16
RUN python3 -m pip install requests==2.28.1
RUN python3 -m pip install boto3==1.26.16
RUN tar --version
COPY bdv2s3.py /bdv2s3.py
CMD ["python", "/bdv2s3.py"]
