ARG ALPINE_VERSION=3.20
FROM alpine:${ALPINE_VERSION}
LABEL maintainer="from www.dwhd.org by lookback (mondeolove@gmail.com)"

ENV TERM=linux

RUN \
    set -eux && \
    apk add --no-cache bash bash-completion ca-certificates openssl curl tar iproute2 vim tree ripgrep && \
    sed -i 's@/root:/bin/sh@/root:/bin/bash@' /etc/passwd && \
    install -d /etc/profile.d && \
    cat <<'EOF' > /etc/profile.d/99-custom.sh
alias ls="ls --color=auto"
alias vi="vim"
alias tree="tree -C -lha -D --du --timefmt '%F %T'"
alias rg="rg --smart-case"

cd ~
ALPINE_RELEASE="$(cat /etc/alpine-release 2>/dev/null || echo unknown)"
PS1="[\[\033[0;34m\]\u\[\033[0;37m\]@\[\033[0;32m\]Docker-Container-Alpine_${ALPINE_RELEASE}\[\033[0;33m\] \w\[\033[0;37m\]]\[\033[0;31m\]\$\[\033[00m\] "
EOF
RUN \
    set -eux && \
    printf '\nif [ -f /etc/profile.d/99-custom.sh ]; then\n\t. /etc/profile.d/99-custom.sh\nfi\n' >> /etc/bash/bashrc && \
    printf '\nif [ -f /etc/bash/bashrc ]; then\n\t. /etc/bash/bashrc\nfi\n' >> /root/.bashrc

SHELL ["/bin/bash", "-lc"]

WORKDIR /root
CMD ["bash", "-l"]
