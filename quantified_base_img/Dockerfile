FROM python:2.7.13
ADD . /requirements
WORKDIR /requirements
RUN apt-get update
RUN apt-get install -y mysql-client
RUN apt-get install -y net-tools
RUN pip install -r requirements.txt