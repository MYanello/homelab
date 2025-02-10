# syntax=docker/dockerfile:1.0.0-experimental

ARG BUILD_ENV

FROM redhat/ubi8-minimal:latest AS base

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=078704701727.dkr.ecr.us-east-1.amazonaws.com/eclipse-temurin:11.0.19_7-jre-focal $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"


RUN microdnf upgrade -y --refresh --nodocs \
    --setopt=install_weak_deps=0 && \
    microdnf install -y --nodocs \
    python39-pip \
    tar \
    procps-ng \
    git \
    util-linux-user

RUN mkdir -p -m 0600 ~/.ssh &&\
    ssh-keyscan github.com >> ~/.ssh/known_hosts

WORKDIR /opt/rescale

RUN python3.9 -m venv venv && . venv/bin/activate



RUN microdnf remove -y tar \
     git \
     openssh-clients \
      util-linux-user; \
      microdnf -y clean all && \
      rm -rf /var/dnf/cache

STOPSIGNAL SIGUSR2
