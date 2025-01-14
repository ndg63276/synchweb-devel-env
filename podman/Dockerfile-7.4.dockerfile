FROM centos:7

WORKDIR /app
 
# Install httpd, PHP, git and required dependencies
RUN yum install wget git tar xz-utils httpd mod_ssl -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/remi-php74.repo && \
    yum install -y php php-mysqlnd php-mbstring php-xml php-gd php-fpm php-cli php-xdebug

# Add php to path
ENV PATH="${PATH}:/opt/remi/php74/root/usr/bin:/opt/remi/php74/root/usr/sbin"
 
# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/tmp --filename=composer
 
# Copy config
COPY httpd.conf /etc/httpd/conf/

RUN chmod 744 /etc/httpd/conf/httpd.conf
 
EXPOSE 8082 9003
ENTRYPOINT ["/app/SynchWeb/entrypoint.bash", "-7"]
