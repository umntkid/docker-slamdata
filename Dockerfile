FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive

# Install Java 8 JRE
RUN apt-get update && apt-get install -y software-properties-common wget unzip
ENV LANG en_US.UTF-8
RUN locale-gen $LANG
RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update && apt-get install -y openjdk-8-jre
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# Install slamdata
COPY slamdata.sh /slamdata.sh
RUN chmod +x slamdata.sh
RUN echo '\n/usr/local/slamdata\n\n'| ./slamdata.sh

# install packages
RUN apt-get update \
	&& apt-get install -y nginx openssl curl python make g++

# TODO change password after demo
RUN printf "user:$(openssl passwd -crypt 1234567)\n" >> /etc/nginx/.htpasswd

RUN mkdir /etc/nginx/ssl

# certificate for nginx (only)
RUN openssl req \
        -days 3650 \
        -keyout /etc/nginx/ssl/slamdata.key \
        -newkey rsa:2048 \
        -nodes \
        -out /etc/nginx/ssl/slamdata.crt \
        -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=slamdata" \
        -x509

COPY nginx-conf /etc/nginx/sites-available/slamdata
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/slamdata /etc/nginx/sites-enabled/slamdata

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

VOLUME /root/.config/quasar

EXPOSE 443
