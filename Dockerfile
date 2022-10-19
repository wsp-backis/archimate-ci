FROM docker.io/ubuntu:20.04

ARG ARCHI_VERSION=4.9.3
ARG COARCHI_VERSION=0.8.4
ARG TZ=UTC
ARG UID=1000

WORKDIR /archi
COPY app .

SHELL ["/bin/bash", "-o", "pipefail", "-x", "-e", "-u", "-c"]

# DL3015 ignored for suppress org.freedesktop.DBus.Error.ServiceUnknown
# hadolint ignore=DL3008,DL3015
RUN groupadd --gid "$UID" archi && \
    useradd --uid "$UID" --gid archi --shell /bin/bash \
      --home-dir /archi --create-home archi && \
    # Set timezone \
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && \
    echo "$TZ" > /etc/timezone && \
    # Install dependecies \
    apt-get update && \
    # apt install -y software-properties-common && \
    apt-get install -y \
      ca-certificates \
      libgtk2.0-cil \
      libswt-gtk-4-jni \
      dbus-x11 \
      xvfb \
      # curl \
      git \
      openssh-client \
      unzip \
      python3 \
      python3-pip && \
    apt-get clean && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    # Download & extract Archimate tool \
    # curl 'https://www.archimatetool.com/downloads/archi/' -k --request POST \
    #  --data-raw "zoob=$ARCHI_VERSION/Archi-Linux64-$ARCHI_VERSION.tgz" \
    #  --output - | \  
    tar zxf Archi-Linux64-$ARCHI_VERSION.tgz -C /opt/ 2> /dev/null && \
    chmod +x /opt/Archi/Archi && \
    # Install Collaboration plugin \
    mkdir -p /root/.archi4/dropins /archi/report /archi/project && \
    # curl 'https://www.archimatetool.com/downloads/coarchi/' --request POST \
    #   --data-raw "zoob=coArchi_$COARCHI_VERSION.archiplugin" \
    #   --output modelrepository.archiplugin && \
    unzip coArchi_$COARCHI_VERSION.archiplugin -d /root/.archi4/dropins/ && \
    rm coArchi_$COARCHI_VERSION.archiplugin && \
    chown -R "$UID:0" /archi && \
    chmod -R g+rw /archi

RUN pip3 install -r azure_storage/requirements.txt

COPY entrypoint.sh /opt/Archi/
COPY app/azure_storage /opt/Archi
USER archi

ENTRYPOINT [ "/opt/Archi/entrypoint.sh" ]
