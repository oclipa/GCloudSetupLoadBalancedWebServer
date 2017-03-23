FROM google/debian:wheezy
MAINTAINER Steve Hall <https://github.com/oclipa>

RUN apt-get update && \
    apt-get install -y python-dev python-pip python-mysqldb && \
    pip install flask

ADD app /app

EXPOSE 80

CMD [ "python", "/app/app.py" ]