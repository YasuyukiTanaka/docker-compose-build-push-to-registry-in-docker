FROM ubuntu:18.04

# update packages
RUN \
  apt-get update && \
  apt-get upgrade -y; 



RUN apt install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install -y build-essential libpq-dev libssl-dev openssl libffi-dev zlib1g-dev
RUN apt-get install -y python3-pip python3.7-dev
RUN apt-get install -y python3.7
RUN apt-get install -y docker.io



COPY ./pip_requirements.txt /tmp
RUN pip3 install -r /tmp/pip_requirements.txt > /dev/null

COPY entrypoint.sh /entrypoint.sh
RUN chmod 711 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

