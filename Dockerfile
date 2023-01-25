FROM archlinux as certbuilder

RUN pacman -Sy --noconfirm openssl go git gcc

RUN mkdir /root/.mitmproxy
RUN openssl genrsa -out /root/.mitmproxy/mitmproxy-ca.key 2048
RUN openssl req -new -x509 -key /root/.mitmproxy/mitmproxy-ca.key -out /root/.mitmproxy/mitmproxy-ca.crt -subj "/C=US/ST=California/O=mitmproxy"
RUN cat /root/.mitmproxy/mitmproxy-ca.key /root/.mitmproxy/mitmproxy-ca.crt > /root/.mitmproxy/mitmproxy-ca.pem

RUN mkdir /root/lcontainerd
ARG LCTR_REF=HEAD
RUN git clone https://github.com/dmcgowan/lcontainerd.git /root/lcontainerd && git -C /root/lcontainerd/ checkout "${LCTR_REF}"
RUN cd /root/lcontainerd/cmd/lctr && go build -o /usr/local/bin/lctr .

COPY ./start-session.sh /root/.start-session.sh
COPY ./bash_profile /root/.bash_profile

RUN mkdir -p /root/.local/share/lctr/creds

# Cleanup root directory for copy
RUN rm -rf /root/go /root/lcontainerd

FROM archlinux

RUN pacman -Sy --noconfirm net-tools mitmproxy tmux p11-kit

COPY --from=certbuilder /usr/local/bin /usr/local/bin
COPY --from=certbuilder /root /root

RUN trust anchor --store /root/.mitmproxy/mitmproxy-ca.crt

ENV HOME=/root
ENV CONTAINERD_CREDENTIAL_DIRECTORY=/root/.local/share/lctr/creds
ENV HTTPS_PROXY=localhost:8888

CMD "/root/.start-session.sh"
