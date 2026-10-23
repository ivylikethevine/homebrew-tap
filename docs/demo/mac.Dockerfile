# The demo's client: a Linux Homebrew dressed as a Mac with a stock setup. One
# user, a hostname macOS would pick, macOS's own /etc/zshrc prompt, and the
# ~/.zprofile line Homebrew's installer asks for. Homebrew sits at the Linux
# default prefix: any other prefix warns on every install.
FROM ubuntu:24.04

# the Homebrew release the demo runs; tap trust (6.0) is the behavior shown
ARG BREW_VERSION=7.0.10

# Homebrew's documented Linux requirements, plus the shell and the ssh client;
# unpinned, as the base tag fixes the release and none of them is on screen
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential ca-certificates curl file git openssh-client procps zsh \
  && rm -rf /var/lib/apt/lists/*

# the zshrc lines are for zsh to expand, not the build
# hadolint ignore=SC2016
RUN mkdir /Users \
  && useradd --create-home --home-dir /Users/maya --shell /bin/zsh maya \
  && mkdir -p /home/linuxbrew/.linuxbrew \
  && chown -R maya:maya /home/linuxbrew \
  && printf '%s\n' '# macOS /etc/zshrc' \
    'HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history' \
    'HISTSIZE=2000' 'SAVEHIST=1000' \
    'PS1="%n@%m %1~ %# "' >/etc/zsh/zshrc

USER maya
WORKDIR /Users/maya
# What a Terminal tab has and `docker exec` does not set. Brew updates only at
# build time, so a render never waits on it; analytics and hints are notices
# a first run prints.
ENV USER=maya SHELL=/bin/zsh LANG=C.UTF-8 TERM=xterm-256color \
  HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_ENV_HINTS=1

# The installer's steps by hand: the clone on a `stable` branch, the link,
# then a first run to fetch portable Ruby and the formula API cache.
RUN git clone -q --branch "$BREW_VERSION" https://github.com/Homebrew/brew \
    /home/linuxbrew/.linuxbrew/Homebrew \
  && git -C /home/linuxbrew/.linuxbrew/Homebrew checkout -q -B stable \
  && mkdir /home/linuxbrew/.linuxbrew/bin \
  && ln -s ../Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew \
  && /home/linuxbrew/.linuxbrew/bin/brew info --formula hello >/dev/null

# hadolint ignore=SC2016
RUN printf '%s\n' 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >.zprofile \
  && mkdir -m 700 .ssh \
  && ssh-keygen -q -t ed25519 -N "" -C maya@Mayas-MacBook-Pro -f .ssh/id_ed25519 \
  && printf '%s\n' 'Host web-prod' '  User deploy' \
    '  StrictHostKeyChecking no' '  UserKnownHostsFile /dev/null' \
    '  LogLevel ERROR' >.ssh/config

CMD ["sleep", "infinity"]
