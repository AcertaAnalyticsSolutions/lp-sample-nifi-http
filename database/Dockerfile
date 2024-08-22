FROM mcr.microsoft.com/mssql/server:2022-CU13-ubuntu-22.04
USER root

RUN mkdir -p /usr/config
WORKDIR /usr/config

COPY . /usr/config

RUN chmod +x /usr/config/entrypoint.sh
RUN chmod +x /usr/config/configure-db.sh

USER mssql
ENTRYPOINT ["./entrypoint.sh"]