FROM docker.io/bitnami/spark:3.0.1-debian-10-r83
# from https://hub.docker.com/r/bitnami/spark
USER root

RUN echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list
RUN apt update
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
RUN apt build-dep -y python3
# install git since it is needed by pre commit hooks
RUN apt install git -y && git --version

RUN pip install --upgrade --no-cache-dir pip
RUN pip install --no-cache-dir wheel
RUN pip install --no-cache-dir pre-commit
RUN pip install --no-cache-dir pipenv

USER 1001

CMD ["/bin/false"]
