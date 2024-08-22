FROM apache/nifi:2.0.0-M4

USER root

RUN apt-get update && apt-get install -y wget

RUN wget https://github.com/microsoft/mssql-jdbc/releases/download/v12.8.0/mssql-jdbc-12.8.0.jre11.jar && \
    mv mssql-jdbc-12.8.0.jre11.jar /opt/nifi/nifi-current/lib/

RUN chown nifi:nifi /opt/nifi/nifi-current/lib/mssql-jdbc-12.8.0.jre11.jar

COPY --chown=nifi:nifi flow.json.gz /opt/nifi/nifi-current/conf/

USER nifi

ENTRYPOINT ["../scripts/start.sh"]