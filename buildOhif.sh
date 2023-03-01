#!/bin/bash

mkdir $HOME/docker
mkdir $HOME/docker/Viewers
git clone -b v3-stable https://github.com/OHIF/Viewers.git $HOME/docker/Viewers
curl -LJO -o $HOME/docker/Viewers/.docker https://raw.githubusercontent.com/cplatt-iso/OHIF/main/Config/ohif-v3-default.js 
curl -LJO -o $HOME/docker/Viewers/.docker https://raw.githubusercontent.com/cplatt-iso/OHIF/main/Config/nginx-default.conf
cd $HOME/docker/Viewers

sed -i '/USER nginx/a \
COPY --chown=nginx:nginx .docker/nginx-default.conf /etc/nginx/conf.d/default-ssl.conf \
COPY --chown=nginx:nginx .docker/ssl/tiny.insiteone.com.pem /etc/nginx/ssl \
COPY --chown=nginx:nginx .docker/ssl/tiny.insiteone.com.key /etc/nginx/ssl \
' $HOME/docker/Viewers/Dockerfile
sed -i '/ENTRYPOINT \[\"/usr/src/entrypoint.sh\"\]/i \
RUN rm /usr/share/nginx/html/app-config.js || true \
COPY .docker/ohif-v3-default.js /usr/share/nginx/html/app-config.js \
' $HOME/docker/Viewers/Dockerfile



