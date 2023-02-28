ARG debian_version=bullseye

FROM bitnami/minideb:${debian_version}
ARG TINI_VERSION=v0.19.0
ARG TARGETPLATFORM
ARG LIBS_VER_SUPPORT=0.3.0
ARG LIBS_VER_FILE=0.3.0
ARG LIBS_VER_ASSERT=2.1.0
ARG LIBS_VER_DETIK=1.1.0
ARG UID=1001
ARG GID=115

# https://github.com/opencontainers/image-spec/blob/main/annotations.md
# TODO Adapt this to docToolchain needs
LABEL maintainer="Max Hofer"
LABEL org.opencontainers.image.authors="Max Hofer"
LABEL org.opencontainers.image.title="Bats"
LABEL org.opencontainers.image.description="Bash Automated Testing System"
LABEL org.opencontainers.image.url="https://hub.docker.com/repository/docker/maxh/bats"
LABEL org.opencontainers.image.source="https://github.com/mh182/bats-core"
LABEL org.opencontainers.image.base.name="docker.io/bitnami/minideb"

# Install parallel and accept the citation notice (we aren't using this in a
# context where it make sense to cite GNU Parallel).
RUN install_packages ca-certificates gnupg ncurses-bin parallel unzip wget && \
    mkdir -p ~/.parallel && touch ~/.parallel/will-cite \
    && mkdir /code

COPY ./docker /tmp/docker
# default to amd64 when not running in buildx environment that provides target platform
RUN /tmp/docker/install_tini.sh "${TARGETPLATFORM-linux/amd64}"
# Install bats libs
RUN /tmp/docker/install_libs.sh support ${LIBS_VER_SUPPORT}
RUN /tmp/docker/install_libs.sh file ${LIBS_VER_FILE}
RUN /tmp/docker/install_libs.sh assert ${LIBS_VER_ASSERT}
RUN /tmp/docker/install_libs.sh detik ${LIBS_VER_DETIK}

RUN ln -s /opt/bats/bin/bats /usr/local/bin/bats
COPY . /opt/bats/

WORKDIR /code/

ENTRYPOINT ["/tini", "--", "bash", "bats"]
