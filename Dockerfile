FROM ubuntu:latest
MAINTAINER Bioboxes

#install ray
RUN apt-get update
RUN apt-get install -y openssh-server openmpi-bin
ADD bin/Ray /opt/bin/Ray

#add parser and run command 
ADD bbx/ /bbx
RUN chmod a+x /bbx/run/default
ENV PATH /bbx/run:$PATH

#load the input-validator
ENV BASE_URL https://s3-us-west-1.amazonaws.com/bioboxes-tools/validate-input
ENV VERSION  validate-input-current.tar.xz
RUN apt-get install -y wget
RUN apt-get install -y xz-utils
RUN mkdir -p /bbx/bin/biobox-validator
RUN wget --quiet --output-document - ${BASE_URL}/${VERSION} |  tar xJf - --directory /bbx/bin/biobox-validator  --strip-components=1

#install python 
RUN apt-get install python
RUN wget -O /opt/bin/PyYAML-3.11.tar.gz http://pyyaml.org/download/pyyaml/PyYAML-3.11.tar.gz
RUN tar xzvf /opt/bin/PyYAML-3.11.tar.gz -C /opt/bin
WORKDIR /opt/bin/PyYAML-3.11
RUN python setup.py install
