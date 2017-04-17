FROM ubuntu:14.04

RUN useradd --system -U -u 500 --home-dir /opt/plone plone \
 && mkdir -p /opt/plone /data/filestorage /data/blobstorage \
 && chown -R plone:plone /opt/plone /data


ENV PLONE_MAJOR=4.3
ENV PLONE_VERSION=4.3.12
ENV PLONE_MD5=62291e00e1b86b8794772e6841a29570

LABEL plone.version=$PLONE_VERSION

RUN buildDeps="curl sudo python-setuptools python-dev python-imaging wv poppler-utils zlib1g-dev python-virtualenv libjpeg62-dev libreadline-gplv2-dev git build-essential libssl-dev libxml2-dev libxslt1-dev libbz2-dev" \
 && runDeps="libxml2 libxslt1.1 libjpeg62 rsync ca-certificates" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && sudo -u plone git clone https://github.com/plonegovbr/portal.buildout.git /opt/plone/portal.buildout \
 && cd /opt/plone/portal.buildout \
 && sudo -u plone git checkout tags/1.1.5.2 \
 && sudo -u plone echo '[buildout]' > buildout.cfg \
 && sudo -u plone echo '\nextends=' >> buildout.cfg \
 && sudo -u plone echo '     production.cfg' >> buildout.cfg \
 && sudo -u plone echo '     ' >> buildout.cfg \
 && sudo -u plone echo '     [hosts]' >> buildout.cfg \
 && sudo -u plone echo '     supervisor = 127.0.0.1' >> buildout.cfg \
 && sudo -u plone echo '     haproxy = 0.0.0.0' >> buildout.cfg \
 && sudo -u plone echo '     instance = 127.0.0.1' >> buildout.cfg \
 && sudo -u plone echo '     zeoserver = 127.0.0.1' >> buildout.cfg \
 && sudo -u plone echo '     ' >> buildout.cfg \
 && sudo -u plone echo '     [ports]' >> buildout.cfg \
 && sudo -u plone echo '     supervisor = 9001' >> buildout.cfg \
 && sudo -u plone echo '     haproxy = 8000' >> buildout.cfg \
 && sudo -u plone echo '     instance = 8080' >> buildout.cfg \
 && sudo -u plone echo '     zeoserver = 8100' >> buildout.cfg \
 && sudo -u plone echo '     ' >> buildout.cfg \
 && sudo -u plone echo '     [users]' >> buildout.cfg \
 && sudo -u plone echo '     zope = admin' >> buildout.cfg \
 && sudo -u plone echo '     os = plone' >> buildout.cfg \
 && sudo -u plone echo '     ' >> buildout.cfg \
 && sudo -u plone echo '     [supervisor-settings]' >> buildout.cfg \
 && sudo -u plone echo '     user = admin' >> buildout.cfg \
 && sudo -u plone echo '     password = 4dm1n${users:zope}' >> buildout.cfg \
 && sudo -u plone python bootstrap.py -c buildout.cfg \
 && sudo -u plone ./bin/buildout -c buildout.cfg \

VOLUME /data /opt/plone

EXPOSE 8000
USER plone
WORKDIR /opt/plone/portal.buildout/instance

ENTRYPOINT ["/opt/plone/portal.buildout/bin/supervisord"]
