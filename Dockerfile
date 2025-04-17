ARG KANIKO_RELEASE="1.23.2"

FROM debian:bookworm-slim AS debian

# containerd/ARC attempt to run shell stuff inside the container, use the debug image since it
# contains busybox + utilities
FROM gcr.io/kaniko-project/executor:v${KANIKO_RELEASE}-debug

# lie about the container being Debian to make some ARC stuff behave nicely
COPY --from=debian /etc/os-release /etc/os-release

# ARC runs nodejs actions on the workflow container by mounting node to the container. nodejs is
# dynamically linked and the Kaniko container doesn't contain any supporting libraries for node to
# run, so copy required libraries to the container
COPY --from=debian /lib/x86_64-linux-gnu/libdl.so.2 /lib/x86_64-linux-gnu/libdl.so.2
COPY --from=debian /lib/x86_64-linux-gnu/libstdc++.so.6 /lib/x86_64-linux-gnu/libstdc++.so.6
COPY --from=debian /lib/x86_64-linux-gnu/libm.so.6 /lib/x86_64-linux-gnu/libm.so.6
COPY --from=debian /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/libgcc_s.so.1
COPY --from=debian /lib/x86_64-linux-gnu/libpthread.so.0 /lib/x86_64-linux-gnu/libpthread.so.0
COPY --from=debian /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libc.so.6
COPY --from=debian /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2

WORKDIR /workspace
ENTRYPOINT ["/kaniko/executor"]
