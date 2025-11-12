FROM registry.redhat.io/devspaces/udi-rhel9@sha256:8f980b826039e2a36855a3d19ce163bb8762ff10a34c885ad744698878168b57

USER root

RUN dnf install -y \
    krb5-workstation \
    && dnf clean all

# Install Python v3.12 and set symlinks with high priority in /usr/local/bin
RUN dnf install -y \
    python3.12 \
    python3.12-devel \
    python3.12-pip \
    && ln -sf /usr/bin/python3.12 /usr/local/bin/python \
    && ln -sf /usr/bin/pip3.12 /usr/local/bin/pip \
    # AGRESIVNÍ KROK: Přepsání symlinku v adresáři venv, který má nejvyšší prioritu v PATH při běhu.
    # Vytvoříme cestu a přesměrujeme symlink na Python 3.12.
    && mkdir -p /home/tooling/.venv/bin/ \
    && ln -sf /usr/bin/python3.12 /home/tooling/.venv/bin/python \
    && python --version \
    && dnf clean all

# Install XFCE4 and noVNC
#RUN dnf install -y epel-release && \
#    dnf groupinstall -y "Xfce" && \
#    dnf install -y tigervnc-server xorg-x11-fonts-* && \
#    curl -sL https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz | tar xz -C /opt && \
#    mv /opt/noVNC-1.4.0 /opt/noVNC && \
#    ln -s /opt/noVNC/utils/novnc_proxy /usr/local/bin/novnc_proxy && \
#    dnf clean all

# Set the PATH so that /usr/local/bin has priority
ENV PATH=/usr/local/bin:$PATH

# A last pass to make sure that an arbitrary user can write in $HOME
RUN chgrp -R 0 /home && chmod -R g=u /home

USER 10001
ENV HOME=/home/user
# /usr/libexec/podman/catatonit is used to reap zombie processes
ENTRYPOINT ["/usr/libexec/podman/catatonit","--","/entrypoint.sh"]
WORKDIR /projects
CMD tail -f /dev/null

