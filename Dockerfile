FROM ubuntu:14.04

RUN useradd --system --shell /bin/bash --comment 'Plone Administrator' \
  --user-group -m --home-dir /opt/plone plone \
 && mkdir -p /opt/plone /data/filestorage /data/blobstorage \
 && chown -R plone:plone /opt/plone /data

ENV PLONE_MAJOR=4.3
ENV PLONE_VERSION=4.3.12

LABEL plone.version=$PLONE_VERSION
LABEL os="ubuntu" os.version="14.04"

RUN buildDeps="curl sudo python-setuptools python-dev build-essential libssl-dev libxml2-dev libxslt1-dev libbz2-dev libjpeg62-dev zlib1g-dev python-imaging wv poppler-utils git ca-certificates" \
 && runDeps="libxml2 libxslt1.1 libjpeg62 rsync" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && chown -R plone:plone /opt/plone /data \
 && sudo -u plone git clone https://github.com/plonegovbr/portal.buildout.git /opt/plone/portal.buildout \
 && chown -R plone:plone /opt/plone /data \
 && cd /opt/plone/portal.buildout \
 && apt-get install -y --no-install-recommends $runDeps \
 && sudo -u plone git checkout tags/1.1.5.2 \
 && sudo -u plone echo "[buildout]" > /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "extends =" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "    production.cfg" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "[hosts]" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "supervisor = 127.0.0.1" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "haproxy = 0.0.0.0" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "instance = 127.0.0.1" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "zeoserver = 127.0.0.1" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "[ports]" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "supervisor = 9001" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "haproxy = 8000" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "instance = 8080" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "zeoserver = 8100" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "[users]" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "zope = admin" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "os = plone" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "[supervisor-settings]" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo "user = admin" >> /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone echo 'password = 4dm1n${users:zope}' >> /opt/plone/portal.buildout/buildout.cfg \
 && chown -R plone:plone /opt/plone /data \
 && sudo -u plone python /opt/plone/portal.buildout/bootstrap.py -c /opt/plone/portal.buildout/buildout.cfg \
 && sudo -u plone python /opt/plone/portal.buildout/bin/buildout -c /opt/plone/portal.buildout/buildout.cfg \
 && sed -i 's/^nodaemon = false$/nodaemon = true/' /opt/plone/portal.buildout/parts/supervisor/supervisord.conf

RUN sudo -u plone /opt/plone/portal.buildout/bin/supervisord

# VOLUME /data /opt/plone/portal.buildout

EXPOSE 8000
USER plone
#WORKDIR /opt/plone/portal.buildout/instance
WORKDIR /opt/plone/portal.buildout

#ENTRYPOINT ["/opt/plone/portal.buildout/bin/supervisorctl"]
ENTRYPOINT ["/opt/plone/portal.buildout/bin/supervisord"]
#CMD ["start"]
