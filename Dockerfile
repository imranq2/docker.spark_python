FROM docker.io/bitnami/spark:3.0.1-debian-10-r103
# from https://hub.docker.com/r/bitnami/spark
USER root

RUN echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# install git since it is needed by pre commit hooks
RUN apt update && apt-get clean

RUN pip install --upgrade --no-cache-dir pip && \
    pip install --no-cache-dir wheel && \
    pip install --no-cache-dir pre-commit && \
    pip install --no-cache-dir pipenv

COPY Pipfile* /helix.pipelines/
WORKDIR /helix.pipelines

RUN pipenv sync --system && \
    pipenv sync --dev --system

USER 1001
