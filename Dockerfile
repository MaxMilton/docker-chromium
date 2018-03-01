# Run the Chromium browser in a container

# docker build -t local/chromium .
# docker build --no-cache -t local/chromium .

FROM debian:testing-slim

RUN set -xe \
  && apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    fonts-liberation \
    fonts-roboto \
    fonts-symbola \
    libcanberra-gtk-module \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
  && rm -rf /var/lib/apt/lists/* \
  # add chromium user and set directory permissions
  && groupadd -r -g 6006 chromium \
  && useradd -r -u 6006 -s /sbin/nologin -g chromium -G audio,video chromium \
  && mkdir -p /data \
  && mkdir -p /home/chromium/Downloads \
  && chown -R chromium:chromium /data /home/chromium \
  # remove unwanted chromium flags
  && rm /etc/chromium.d/extensions \
  # unset SUID on all files
  && for i in $(find / -perm /6000 -type f); do chmod a-s $i; done

# override default chromium launcher
COPY chromium /usr/bin/chromium

# custom chromium flags
COPY default-flags /etc/chromium.d/default-flags

# run as non privileged user
USER chromium

ENTRYPOINT ["/usr/bin/chromium"]
CMD ["about:blank"]
