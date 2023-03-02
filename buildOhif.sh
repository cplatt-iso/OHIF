#!/bin/bash

echo "Caching sudo - we will need it later"
sudo -v

SSL_CERT=$HOME/ssl/tiny.insiteone.com.pem
SSL_KEY=$HOME/ssl/tiny.insiteone.com.key

BASE_WORKDIR=$HOME/docker
OHIFDIR=$BASE_WORKDIR/Viewers

echo "Setting up directories"
# set up directories 
[ -d $BASE_WORKDIR ] || mkdir -v $BASE_WORKDIR
[ -d $OHIFDIR ] || mkdir -v $OHIFDIR

echo "Cloning https://github.com/OHIF/Viewers.git"
# clone the v3-stable repository
git clone -b v3-stable https://github.com/OHIF/Viewers.git $OHIFDIR

echo "Setting up certificates"
# put certs in place
[ -d $OHIFDIR/.docker/ssl ] || mkdir -v $OHIFDIR/.docker/ssl
cp -v $SSL_CERT $OHIFDIR/.docker/ssl
cp -v $SSL_KEY $OHIFDIR/.docker/ssl

echo "Pulling OHIF and nginx configurations from github"
# grab configuration files from uca git repository
curl $OHIFDIR/.docker/ohif-v3-default.js https://raw.githubusercontent.com/cplatt-iso/OHIF/main/Config/ohif-v3-default.js > $OHIFDIR/.docker/ohif-v3-default.js
curl $OHIFDIR/.docker/nginx-default.conf https://raw.githubusercontent.com/cplatt-iso/OHIF/main/Config/nginx-default.conf > $OHIFDIR/.docker/nginx-default.conf

echo "Modifying Dockerfile to incorporate our configuration"
# Modify Dockerfile 
sed -i '/USER nginx/a \
COPY --chown=nginx:nginx .docker/nginx-default.conf /etc/nginx/conf.d/default-ssl.conf \
RUN mkdir /etc/nginx/ssl \
COPY --chown=nginx:nginx .docker/ssl/tiny.insiteone.com.pem /etc/nginx/ssl/tiny.insiteone.com.pem \
COPY --chown=nginx:nginx .docker/ssl/tiny.insiteone.com.key /etc/nginx/ssl/tiny.insiteone.com.key' $OHIFDIR/Dockerfile

sed -i '/ENTRYPOINT \[\"\/usr\/src\/entrypoint.sh\"\]/i \
USER root \
RUN rm /usr/share/nginx/html/app-config.js || true \
COPY .docker/ohif-v3-default.js /usr/share/nginx/html/app-config.js' $OHIFDIR/Dockerfile

cd $OHIFDIR
echo "Building docker image"
sudo docker build -t ohif/viewer:uca .

