# Collaboration server version 9+

FROM bellsoft/liberica-openjdk-debian:11

# Install collaboration server

ADD dist /opt/dist

RUN cd /opt/dist && tar -xf ./*.gz && \
    chmod +x ./1ce-installer-cli && \
    ./1ce-installer-cli install

RUN apt-get update && \
    apt-get install gawk -y

ADD scripts /opt/scripts

RUN cd /opt/scripts && \
    cp ./ring.sh /bin/ring && \
    chmod +x /bin/ring && \
    cp ./run.sh /bin/run_cs && \
    chmod +x /bin/run_cs

RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /opt/dist/*

# Install and create services

RUN useradd es_user && \
    mkdir -p /var/opt/cs/elasticsearch && \
    chown es_user:es_user /var/opt/cs/elasticsearch

RUN ring hazelcast instance create --dir /var/opt/cs/hazelcast && \
    ring elasticsearch instance create --dir /var/opt/cs/elasticsearch --owner es_user && \
    ring cs instance create --dir /var/opt/cs/cs

RUN ring hazelcast --instance hazelcast service create --init-system sysv --stopped --java-home $JAVA_HOME && \
    ring elasticsearch --instance elasticsearch service create --username es_user --init-system sysv --stopped --java-home $JAVA_HOME && \
    ring cs --instance cs service create --init-system sysv --stopped --java-home $JAVA_HOME

EXPOSE 9094

ENTRYPOINT [ "run_cs" ]

# DEBUG
#CMD [ "/bin/bash", "-c",  "while true; do sleep 10; date; done"]

