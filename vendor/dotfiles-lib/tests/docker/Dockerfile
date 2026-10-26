FROM ubuntu:26.04

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        bash coreutils diffutils findutils grep sed ncurses-bin shellcheck shunit2 util-linux \
    && rm -rf /var/lib/apt/lists/*

ENV TERM=xterm
ENV SHUNIT2=/usr/share/shunit2/shunit2

WORKDIR /workspace
ENTRYPOINT ["/workspace/tests/docker/entrypoint.sh"]
