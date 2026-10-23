# The demo's target: a bare Debian server with the app deployed as a git
# checkout, and one edit made on the box and never committed. The client's
# public key arrives at run time as $PUBKEY.
FROM debian:trixie-slim

# unpinned, as the base tag fixes the release
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends git openssh-server \
  && rm -rf /var/lib/apt/lists/* \
  && useradd --create-home --shell /bin/bash deploy \
  && mkdir -p /run/sshd /srv/app \
  && chown deploy:deploy /srv/app \
  && ssh-keygen -A \
  && printf '%s\n' 'PasswordAuthentication no' 'PermitRootLogin no' \
    'AllowUsers deploy' >/etc/ssh/sshd_config.d/demo.conf \
  && git config --system core.pager cat

USER deploy
WORKDIR /srv/app
ENV GIT_AUTHOR_NAME="Release Bot" GIT_AUTHOR_EMAIL=release@example.com \
  GIT_COMMITTER_NAME="Release Bot" GIT_COMMITTER_EMAIL=release@example.com

RUN git init -q -b main \
  && mkdir config \
  && printf '%s\n' 'from flask import Flask' '' 'app = Flask(__name__)' '' \
    '' '@app.get("/health")' 'def health():' '    return {"ok": True}' >app.py \
  && git add app.py && git commit -q -m "Add a health check" \
  && printf '%s\n' '[server]' 'port = 8080' 'workers = 8' >config/settings.toml \
  && git add config && git commit -q -m "Run eight workers" \
  && echo 2.4.1 >VERSION \
  && git add VERSION && git commit -q -m "Release 2.4.1" \
  && sed -i 's/^workers = 8$/workers = 16/' config/settings.toml \
  && mkdir -m 700 /home/deploy/.ssh

# root, for sshd
# hadolint ignore=DL3002
USER root
CMD ["/bin/sh", "-c", "printf '%s\\n' \"$PUBKEY\" >/home/deploy/.ssh/authorized_keys && exec /usr/sbin/sshd -D -e"]
