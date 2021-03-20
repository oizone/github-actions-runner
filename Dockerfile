FROM mcr.microsoft.com/dotnet/sdk:latest
LABEL maintainer="oizone@oizone.net"

ARG GH_RUNNER_VERSION="2.274.2"
ARG TARGETPLATFORM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
ENV ANSIBLE_HOST_KEY_CHECKING=False
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=yes

#RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb
#RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update
RUN apt-get install -y --no-install-recommends python3 unzip xorriso python3-boto3 jq
#RUN apt-get install -y --no-install-recommends python3 unzip xorriso python3-boto3 powershell

WORKDIR /actions-runner
COPY install_actions.sh /actions-runner

RUN chmod +x /actions-runner/install_actions.sh \
  && /actions-runner/install_actions.sh ${GH_RUNNER_VERSION} ${TARGETPLATFORM} \
  && rm /actions-runner/install_actions.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
