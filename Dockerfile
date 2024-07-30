FROM alpine

ENV TERM=screen-256color
ENV LANG=C.UTF-8
ENV UID=1000
ENV GID=1000

ADD run.sh /

RUN BUILD_DEPS=" \
    cmake \
    gettext-dev \
    asciidoctor \
    ruby-dev \
    lua-dev \
    aspell-dev \
    build-base \
    libcurl \
    libintl \
    zlib-dev \
    curl-dev \
    perl-dev \
    gnutls-dev \
    python3-dev \
    ncurses-dev \
    libgcrypt-dev \
    ca-certificates \
    jq \
    tar" 
RUN apk -U upgrade && apk add \
    ${BUILD_DEPS} \
    gettext \
    gnutls \
    ncurses \
    libgcrypt \
    python3 \
    su-exec \
    perl \
    curl \
    shadow
RUN update-ca-certificates
RUN WEECHAT_TARBALL="$(curl -sS https://api.github.com/repos/weechat/weechat/releases/latest | jq .tarball_url -r)"
RUN curl -sSL $WEECHAT_TARBALL -o /tmp/weechat.tar.gz
RUN mkdir -p /tmp/weechat/build
RUN tar xzf /tmp/weechat.tar.gz --strip 1 -C /tmp/weechat
RUN cd /tmp/weechat/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=None -DENABLE_MAN=ON -DENABLE_TCL=OFF -DENABLE_GUILE=OFF -DENABLE_JAVASCRIPT=OFF -DENABLE_PHP=OFF
RUN make && make install
RUN mkdir /weechat
RUN addgroup -g $GID -S weechat
RUN adduser -u $UID -D -S -h /weechat -s /sbin/nologin -G weechat weechat
RUN apk del ${BUILD_DEPS}
RUN rm -rf /var/cache/apk/*
RUN rm -rf /tmp/*

VOLUME /weechat

WORKDIR /weechat

EXPOSE 9001

ENTRYPOINT ["/run.sh"]
CMD ["--dir /weechat"]
