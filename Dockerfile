FROM ubuntu:latest
MAINTAINER Bioboxes

#install ray
RUN apt-get update
RUN apt-get install -y openssh-server openmpi-bin
ADD bin/Ray /opt/bin/Ray

#install python 
RUN apt-get install python
RUN wget -O /opt/bin/PyYAML-3.11.tar.gz http://pyyaml.org/download/pyyaml/PyYAML-3.11.tar.gz
RUN tar xzvf /opt/bin/PyYAML-3.11.tar.gz -C /opt/bin
WORKDIR /opt/bin/PyYAML-3.11
RUN python setup.py install

#add schema, parser and run command 
ADD bbx/ /bbx
RUN chmod a+x /bbx/run/default

#ENTRYPOINT /bbx/run/default
