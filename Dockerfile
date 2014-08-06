# Sal Dockerfile to build a development container running on CentOS 6.5:
#	https://github.com/grahamgilbert/sal

FROM tianon/centos:6.5
MAINTAINER Pepijn Bruienne version: 0.1

ENV ADMIN_NAME Docker User
ENV ADMIN_EMAIL docker@localhost
ENV TIME_ZONE America/New_York

RUN yum update -y
RUN yum groupinstall -y "Development tools"
RUN yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel python-devel httpd httpd-devel git wget

RUN echo "/usr/local/lib" >> /etc/ld.so.conf
RUN /sbin/ldconfig

RUN cd /tmp && \
	wget -q http://python.org/ftp/python/2.7.6/Python-2.7.6.tar.xz && \
	tar xf Python-2.7.6.tar.xz && cd Python-2.7.6 && \
	./configure --prefix=/usr/local --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib" && \
	make && make altinstall
	
RUN cd /tmp && \
	wget -q https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py && \
	python2.7 ez_setup.py

RUN easy_install-2.7 pip
RUN pip2.7 install virtualenv==1.10.1

RUN useradd saluser
RUN groupadd salgroup
RUN usermod -g salgroup saluser

RUN cd /usr/local && \
	virtualenv-2.7 sal_env && \
	chown -R saluser sal_env && \
	/bin/su saluser && \
	bash && \
	cd /usr/local/sal_env && \
	source bin/activate && \
	git clone https://github.com/grahamgilbert/sal.git sal

ADD initial_data.json /usr/local/sal_env/sal/

RUN cd /usr/local/sal_env && \
	source bin/activate && \
	pip install -r sal/setup/requirements.txt && \
	cd sal/sal && \
	cp example_settings.py settings.py && \
	sed -i 's/#.*Your.*/\("Docker User", "docker@localhost"\)/' settings.py && \
	sed -i 's/TIME_ZONE.*/TIME_ZONE = "America\/New_York"/' settings.py && \
	cd .. && \
	python manage.py syncdb --noinput && \
	python manage.py migrate && \
	python manage.py collectstatic --noinput

RUN chkconfig httpd on && service httpd start

RUN cd /usr/local/lib/python2.7/config/ && \
	ln -s ../../libpython2.7.so . && \
	cd /tmp && \
	wget -q https://modwsgi.googlecode.com/files/mod_wsgi-3.4.tar.gz && \
	tar xf mod_wsgi-3.4.tar.gz && cd mod_wsgi-3.4 && \
	export LD_LIBRARY_PATH=/usr/local/lib64 && \
	./configure --with-apxs=/usr/sbin/apxs --with-python=/usr/local/bin/python2.7 && \
	LD_RUN_PATH=/usr/local/lib make && make install &&\
	echo "LoadModule wsgi_module modules/mod_wsgi.so" >> /etc/httpd/conf/httpd.conf && \
	chown -R saluser /usr/local/sal_env
	
ADD sal.conf /etc/httpd/conf.d/sal.conf

RUN service httpd stop
RUN if [[ -n `find /var/run -name "*.sock" -print -quit` ]]; then rm /var/run/*.sock; fi

EXPOSE 8080
ENTRYPOINT ["/usr/sbin/httpd"]
CMD ["-D", "FOREGROUND"]