ARG UBUNTU_VERSION=20.04
FROM ubuntu:${UBUNTU_VERSION} AS builder

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN apt-get update; \
    apt-get install -y --no-install-recommends --no-install-suggests \
        build-essential unzip;

COPY . /build
WORKDIR /build
RUN make

FROM ubuntu:${UBUNTU_VERSION}

LABEL maintainer="Cheyi Lin <cheyi.lin@gmail.com>"

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN apt-get update; \
    apt-get install -y --no-install-recommends --no-install-suggests \
        netbase ca-certificates curl wget; \
    rm -rf /var/lib/apt/lists/*; \
    update-ca-certificates

COPY --from=builder /build/wrk /usr/local/bin/

RUN groupadd -r wrk && useradd -r -g wrk wrk
USER wrk

ENTRYPOINT ["wrk"]