FROM ubuntu:trusty

COPY jre8.tar.gz /jre8.tar.gz
RUN tar -xzvf jre8.tar.gz
RUN rm jre8.tar.gz && mv jre* jre8
RUN update-alternatives --install /usr/bin/java java /jre8/bin/java 1

COPY slamdata.sh /slamdata.sh
RUN chmod +x slamdata.sh
RUN echo '\n/usr/local/slamdata\n\n'| ./slamdata.sh

# install packages
RUN apt-get update \
	&& apt-get install -y nginx openssl curl python make g++

# TODO change password after demo
RUN printf "user:$(openssl passwd -crypt 123456)\n" >> /etc/nginx/.htpasswd

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
#EXPOSE 4000
#CMD SlamData -p 4000