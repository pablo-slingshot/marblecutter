FROM quay.io/mojodna/gdal22
MAINTAINER Seth Fitzsimmons <seth@mojodna.net>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
    bc \
    build-essential \
    curl \
    cython \
    jq \
    python-pip \
    python-wheel \
    python-setuptools && \
  apt-get clean

COPY requirements.txt /opt/oam-dynamic-tiler/requirements.txt

WORKDIR /opt/oam-dynamic-tiler

RUN pip install -U numpy && \
  pip install -Ur requirements.txt && \
  pip install -U awscli && \
  rm -rf /root/.cache

ENV PATH=/opt/oam-dynamic-tiler/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV CPL_TMPDIR /tmp
ENV CPL_VSIL_CURL_ALLOWED_EXTENSIONS .vrt,.tif,.ovr,.msk
ENV GDAL_CACHEMAX 512
ENV GDAL_DISABLE_READDIR_ON_OPEN TRUE
ENV VSI_CACHE TRUE
ENV VSI_CACHE_SIZE 536870912

COPY . /opt/oam-dynamic-tiler

# TODO put this in oam-dynamic-tiler-server
# USER nobody
# EXPOSE 8000
# ENTRYPOINT ["gunicorn", "-k", "gevent", "-b", "0.0.0.0", "--access-logfile", "-", "app:app"]
