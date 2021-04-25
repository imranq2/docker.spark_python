FROM docker.io/bitnami/spark:3.1.1-debian-10-r46
# from https://hub.docker.com/r/bitnami/spark
USER root

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

COPY Pipfile* /helix.pipelines/
WORKDIR /helix.pipelines
#RUN apt update && apt build-dep -y python3 && apt install git -y && git --version && apt-get clean

# update python 3.7
RUN echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list && \
    pip install --upgrade --no-cache-dir pip && \
    pip install --no-cache-dir wheel && \
    # remove all packages from python 3.6 to avoid confusion
    pip freeze | xargs pip uninstall -y && \
    # uninstall system packages from python 3.6 to avoid confusion
    pip uninstall -y --no-cache-dir wheel && \
    pip uninstall -y --no-cache-dir setuptools && \
    pip uninstall -y --no-cache-dir pip && \
    # install python 3.7
    apt update && \
    apt-get install -y python3 python3-distutils python3-pip git && \
    # set python 3.7 as the default
    update-alternatives --install $(which python3) python /usr/bin/python3 1 && \
    python -m pip install --upgrade --no-cache-dir pip && \
    update-alternatives --install $(which pip) pip /usr/local/lib/python3.7/dist-packages/pip 1 && \
    # install system packages
    python -m pip install --upgrade --no-cache-dir pip && \
    python -m pip install --no-cache-dir wheel && \
    python -m pip install --no-cache-dir pre-commit && \
    python -m pip install --no-cache-dir pipenv && \
    pipenv sync --dev --system && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# this part is not workng.  Spark complains about not finding the kafka classes.  Need to install the dependencies
#RUN apt-get -y install maven && \
#    mvn dependency:get -Ddest=/opt/bitnami/spark/jars/ -DgroupId=org.apache.spark -DartifactId=spark-sql-kafka-0-10_2.12 -Dversion=3.0.1
#mvn dependency:get -Ddest=./ -DgroupId=org.apache.spark -DartifactId=spark-sql-kafka-0-10_2.12 -Dversion=3.0.1 -Dtype=pom
#mvn dependency:get -Ddest=./ -Dartifact=org.apache.spark:spark-sql-kafka-0-10_2.12:3.0.1 -Dtype=pom
#mvn dependency:copy-dependencies -DoutputDirectory=/opt/bitnami/spark/jars/
#RUN apt-get install -y curl && \
#    curl https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.12/3.0.1/spark-sql-kafka-0-10_2.12-3.0.1.jar -o /opt/bitnami/spark/jars/spark-sql-kafka-0-10_2.12-3.0.1.jar && \
#mvn dependency:copy-dependencies -DoutputDirectory=OUTPUT_DIR
#RUN apt-get purge -y --auto-remove $buildDeps

# update the AWS jar so it gets newer functionality like WebSecurityProvider
RUN rm /opt/bitnami/spark/jars/aws-java-sdk-bundle*.jar && \
    curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.944/aws-java-sdk-bundle-1.11.944.jar -o /opt/bitnami/spark/jars/aws-java-sdk-bundle-1.11.944.jar && \
    /opt/bitnami/spark/sbin/start-history-server.sh

USER 1001
