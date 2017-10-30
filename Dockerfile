FROM ubuntu:trusty

EXPOSE 3306

RUN (apt-get update || true) && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

VOLUME ["/var/lib/mysql"]

CMD ["/sbin/entrypoint.sh"]
