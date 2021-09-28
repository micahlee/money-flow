FROM jupyter/datascience-notebook

USER root
RUN apt-get update -y && \
    apt-get install -y libpq-dev && \
    pip install sqlalchemy psycopg2

RUN apt-get update -y && \
    apt-get install -y  build-essential patch libtool libffi-dev ruby ruby-dev make
RUN apt-get install -y libzmq3-dev libczmq-dev libsqlite3-dev zlib1g-dev liblzma-dev

RUN gem install cztop iruby pg classifier-reborn

USER $NB_UID
RUN iruby register --force
