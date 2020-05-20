FROM ubuntu:16.04

# update packages
RUN \
  apt-get update && \
  apt-get upgrade -y; 

# install python3.6
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:jonathonf/python-3.6

RUN apt-get update \
  && apt-get install python3.6 python3.6-dev python3-pip make curl git sudo cron -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3.6 python



COPY ./pip_requirements.txt /tmp
RUN pip3 install -r /tmp/pip_requirements.txt > /dev/null

COPY entrypoint.sh /entrypoint.sh
RUN chmod 711 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

