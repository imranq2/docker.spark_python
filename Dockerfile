FROM docker.io/bitnami/spark:3.0.1-debian-10-r142
# from https://hub.docker.com/r/bitnami/spark
USER root

RUN echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt update && apt build-dep -y python3 && apt install git -y && git --version && apt-get clean

RUN pip install --upgrade --no-cache-dir pip && \
    pip install --no-cache-dir wheel && \
    pip install --no-cache-dir pre-commit && \
    pip install --no-cache-dir pipenv

COPY Pipfile* /helix.pipelines/
WORKDIR /helix.pipelines

#RUN pipenv sync --system
#RUN pipenv sync --dev --system
# remove all packages from python 3.6 to avoid confusion
RUN pip freeze | xargs pip uninstall -y

# uninstall system packages from python 3.6 to avoid confusion
RUN pip uninstall -y --no-cache-dir wheel && \
    pip uninstall -y --no-cache-dir setuptools && \
    pip uninstall -y --no-cache-dir pip

# install python 3.7
RUN apt-get install -y python3 python3-distutils python3-pip && apt-get clean

# ste python 3.7 as the default
RUN update-alternatives --install $(which python3) python /usr/bin/python3 1
RUN python -m pip install --upgrade --no-cache-dir pip
RUN update-alternatives --install $(which pip) pip /usr/local/lib/python3.7/dist-packages/pip 1

# install system packages
RUN python -m pip install --upgrade --no-cache-dir pip && \
    python -m pip install --no-cache-dir wheel && \
    python -m pip install --no-cache-dir pre-commit && \
    python -m pip install --no-cache-dir pipenv

RUN apt-get install -y curl && \
    curl https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.12/3.0.1/spark-sql-kafka-0-10_2.12-3.0.1.jar -o /opt/bitnami/spark/jars/spark-sql-kafka-0-10_2.12-3.0.1.jar && \
    apt-get clean

USER 1001
