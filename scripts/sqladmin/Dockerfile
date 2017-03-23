FROM google/debian:wheezy
MAINTAINER Steve Hall <https://github.com/oclipa>

RUN apt-get update && \
    apt-get install -y python-pip && \
    pip install google-api-python-client

ADD app /app

CMD [ "python", "/app/sqladmin.py" ]