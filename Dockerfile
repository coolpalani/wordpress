FROM centos:7
RUN rpm -i https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
RUN yum -y install httpd mariadb-server mariadb php php-mysql php-gd python-pip python-pip
RUN pip install supervisor
RUN mkdir -p /var/lib/data/{mysql,www} /var/lib/data/www/html var/lib/init-data/
RUN mysql_install_db --user=mysql --ldata=/var/lib/mysql

# Install WordPress
WORKDIR  /var/www/html/
RUN curl -LO http://wordpress.org/latest.tar.gz; tar xzf latest.tar.gz ; chown -R apache:apache *
RUN cd /var/www/html/wordpress; cp wp-config-sample.php wp-config.php
RUN rm /var/www/html/latest.tar.gz
# Set database, user and password
RUN sed -i 's/database_name_here/wordpress/' /var/www/html/wordpress/wp-config.php
RUN sed -i 's/username_here/wordpress/' /var/www/html/wordpress/wp-config.php
RUN sed -i 's/password_here/password/' /var/www/html/wordpress/wp-config.php

# make wordpress as DocumentRoot
RUN sed -i 's/\/var\/www\/html/\/var\/www\/html\/wordpress/' /etc/httpd/conf/httpd.conf

RUN mv /var/lib/mysql /var/lib/init-data/
RUN mv /var/www/ /var/lib/init-data/ 
RUN mkdir -p /var/lib/data ; rm -fr /var/www ; rm -fr /var/lib/mysql/aria* ; ln -s /var/lib/data/www /var/ ; ln -s /var/lib/data/mysql /var/lib/
RUN chown -R mysql:mysql /var/lib/mysql /var/lib/init-data/mysql/ /var/lib/data/mysql
RUN chmod 777 -R /var/lib/mysql /var/log/mariadb /var/run/httpd /var/run/mariadb
EXPOSE 80
ADD supervisord.conf /tmp
WORKDIR /tmp
VOLUME /var/lib/data
CMD ["supervisord", "-n", "-c", "/tmp/supervisord.conf" ]
