FROM ubuntu:16.04

# update packages
RUN \
  apt-get update && \
  apt-get upgrade -y; 

RUN apt-get install --no-install-recommends -y python-pip python-setuptools python-wheel

COPY ./pip_requirements.txt /tmp
RUN pip install -r /tmp/pip_requirements.txt > /dev/null

COPY entrypoint.sh /entrypoint.sh
RUN chmod 711 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

