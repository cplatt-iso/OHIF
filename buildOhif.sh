#!/bin/bash
SSL_CERT=$HOME/ssl/tiny.insiteone.com.pem
SSL_KEY=$HOME/ssl/tiny.insiteone.com.key

BASE_WORKDIR=$HOME/docker
OHIFDIR=$BASE_WORKDIR/Viewers

# set up directories 
[ -d $BASE_WORKDIR ] || mkdir $BASE_WORKDIR
[ -d $OHIFDIR ] || mkdir $OHIFDIR

# clone the v3-stable repository
git clone -b v3-stable https://github.com/OHIF/Viewers.git $OHIFDIR

# put certs in place
[ -d $OHIFDIR/.docker/ssl ] || mkdir $OHIFDIR/.docker/ssl

# grab configuration files from uca git repository
curl $OHIFDIR/.docker/ohif-v3-default.js https://raw.githubusercontent.com/cplatt-iso/OHIF/main/Config/ohif-v3-default.js > $OHIFDIR/.docker/ohif-v3-default.js
curl $OHIFDIR/.docker/nginx-default.conf https://raw.githubusercontent.com/cplatt-iso/OHIF/main/Config/nginx-default.conf > $OHIFDIR/.docker/nginx-default.conf
cp $SSL_CERT $OHIFDIR/.docker/ssl
cp $SSL_KEY $OHIFDIR/.docker/ssl

# Modify Dockerfile 
sed -i '/USER nginx/a \
COPY --chown=nginx:nginx .docker/nginx-default.conf /etc/nginx/conf.d/default-ssl.conf \
COPY --chown=nginx:nginx .docker/ssl/tiny.insiteone.com.pem /etc/nginx/ssl \
COPY --chown=nginx:nginx .docker/ssl/tiny.insiteone.com.key /etc/nginx/ssl' $OHIFDIR/Dockerfile

sed -i '/ENTRYPOINT \[\"\/usr\/src\/entrypoint.sh\"\]/i \
USER root \
RUN rm /usr/share/nginx/html/app-config.js || true \
COPY .docker/ohif-v3-default.js /usr/share/nginx/html/app-config.js' $OHIFDIR/Dockerfile

cd $OHIFDIR
sudo docker build -t ohif/viewer:uca .

