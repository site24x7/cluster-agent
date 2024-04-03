FROM ubuntu:20.04

MAINTAINER site24x7<support@site24x7.com>

RUN apt-get update && \
  apt-get install -y python3 python3-dev python3-pip python3-virtualenv && \
  apt-get install -y wget && \
  apt-get install -y vim && \
  apt-get install -y libssl-dev && \
  apt-get install -y zip

ARG WORK_DIR=/home/site24x7

WORKDIR $WORK_DIR

COPY ["entrypoint.sh", "requirements.txt", "gunicorn.conf.py", "logging.xml", "./"]

RUN chmod +x entrypoint.sh

RUN chmod -R 777 $WORK_DIR

RUN pip3 install -r requirements.txt

#No need to provide health check, since it was handled via ReadinessProbe

ENTRYPOINT ["./entrypoint.sh"]

CMD ["/usr/bin/python3", "/home/site24x7/monagent/lib/devops/source/python3.3/src/com/manageengine/monagent/kubernetes/ClusterAgent/HelperAgent.py"]
