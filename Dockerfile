# Sal Dockerfile
FROM phusion/passenger-customizable:0.9.11

MAINTAINER Pepijn Bruienne, Graham Gilbert version: 0.2

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV APPNAME Sal
ENV APP_DIR /home/app/sal
ENV TZ Europe/London
ENV DOCKER_SAL_TZ Europe/London
ENV DOCKER_SAL_ADMINS Docker User, docker@localhost
ENV DOCKER_CRYPT_LANG en_GB

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]
RUN apt-get -y update
RUN /build/utilities.sh
RUN /build/python.sh

RUN apt-get -y install \
    python-setuptools \
    libpq-dev \
    python-dev \
    && easy_install pip

RUN git clone https://github.com/grahamgilbert/sal.git $APP_DIR
RUN pip install -r $APP_DIR/setup/requirements.txt
RUN pip install psycopg2==2.5.3
RUN mkdir -p /etc/my_init.d
ADD nginx/nginx-env.conf /etc/nginx/main.d/
ADD nginx/sal.conf /etc/nginx/sites-enabled/sal.conf
ADD settings.py $APP_DIR/sal/
ADD settings_import.py $APP_DIR/sal/
ADD passenger_wsgi.py $APP_DIR/
ADD django/management/ $APP_DIR/sal/management/
ADD run.sh /etc/my_init.d/run.sh
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-enabled/default

#ADD initial_data.json /usr/local/sal_env/sal/

EXPOSE 8000

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*