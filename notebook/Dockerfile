from jupyter/datascience-notebook

USER root
RUN apt-get update -y && \
    apt-get install -y libpq-dev && \
    pip install sqlalchemy psycopg2
USER $NB_UID
