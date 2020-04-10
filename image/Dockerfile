FROM erlang:22.3.2-alpine as builder

RUN apk --no-cache --update --available upgrade \
 && apk add --update --no-cache \
    build-base \
    bsd-compat-headers \
    git \
    openssl-dev \
    snappy-dev \
 && addgroup --gid 10000 vernemq \
 && adduser --uid 10000 -H -D -G vernemq -h /vernemq vernemq \
 && install -d -o vernemq -g vernemq /vernemq

ARG VERNEMQ_VERSION

WORKDIR /vernemq

RUN git clone --branch ${VERNEMQ_VERSION} --single-branch https://github.com/vernemq/vernemq.git . \
 && make rel

FROM alpine:3.11
LABEL maintainer="Jeff Grunewald <jeff@grunewalddesign.com>"

RUN apk --no-cache --update --available upgrade \
 && apk add --no-cache ncurses-libs \
    libstdc++ \
    openssl \
    curl \
    jq \
    snappy-dev \
    bash \
 && rm -rf /var/cache/apk/* \
 && addgroup --gid 10000 vernemq \
 && adduser --uid 10000 -H -D -G vernemq -h /vernemq vernemq \
 && install -d -o vernemq -g vernemq /vernemq

ENV DOCKER_VERNEMQ_KUBERNETES_LABEL_SELECTOR="app=vernemq" \
    DOCKER_VERNEMQ_KUBERNETES_APP_LABEL=vernemq \
    DOCKER_VERNEMQ_LOG__CONSOLE=console \
    DOCKER_VERNEMQ_LOG__CONSOLE__LEVEL=info \
    DOCKER_VERNEMQ_ALLOW_ANONYMOUS=off \
    PATH="/vernemq/bin:$PATH"

WORKDIR /vernemq

RUN bash -c 'mkdir ./{data,etc,log}'

COPY --from=builder /vernemq/_build/default/rel/vernemq ./
COPY --chown=10000:10000 assets/run_vernemq.sh /usr/local/bin/run_vernemq
COPY --chown=10000:10000 assets/vm.args /vernemq/etc/vm.args
COPY --chown=10000:10000 assets/vmq.acl /vernemq/etc/vmq.acl
COPY --chown=10000:10000 assets/vernemq.conf /vernemq/etc/vernemq.conf
RUN ln -s /vernemq/etc /etc/vernemq \
 && ln -s /vernemq/data /var/lib/vernemq \
 && ln -s /vernemq/log /var/log/vernemq \
 && chmod u+x /usr/local/bin/run_vernemq \
 && chown -R vernemq /vernemq \
 && chmod u+x /vernemq/bin \
 && chmod -R g=u /vernemq /etc/passwd

EXPOSE 1883 \
       4369 \
       8883 \
       8888 \
       8080 \
       9100 9101 9102 9103 9104 9105 9106 9107 9108 9109 \
       44053

VOLUME ["/vernemq/log", "/vernemq/data", "/vernemq/etc"]

HEALTHCHECK CMD vernemq ping | grep -q pong

USER vernemq
CMD ["run_vernemq"]
