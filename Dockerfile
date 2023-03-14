FROM debian:bookworm-slim AS chktex
ARG CHKTEX_VERSION=1.7.8
WORKDIR /tmp/workdir
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends g++ make perl wget
RUN wget -qO- http://download.savannah.gnu.org/releases/chktex/chktex-${CHKTEX_VERSION}.tar.gz | \
    tar -xz --strip-components=1
RUN ./configure && \
    make && \
    mv chktex /tmp && \
    rm -r *


FROM debian:bookworm-slim as biber
ARG BIBER_VERSION=2.19
WORKDIR /tmp/workdir
RUN echo "deb http://ftp.us.debian.org/debian buster main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends \
    ca-certificates \
    cpanminus \
    gcc \
    git \
    icu-devtools \
    libcrypt-dev \
    libicu-dev \
    libicu63 \
    liblzma-dev \
    libperl-dev \
    libssl-dev \
    libxslt-dev \
    locales \
    make \
    perl \
    openssl \
    wget \
    zlib1g-dev
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    locale-gen en_US.UTF-8
RUN git clone https://github.com/redhotpenguin/perl-Archive-Zip.git /tmp/perl-Archive-Zip && \
    cd /tmp/perl-Archive-Zip && \
    perl Makefile.PL && \
    make && \
    make test && \
    make install && \
    cpanm pp && \
    cpanm Net::SSLeay && \
    cpanm IO::Socket::SSL && \
    cpanm LWP::Protocol::https && \
    cpanm PAR && \
    cpanm PAR::Dist && \
    cpanm PAR::Packer
RUN git clone -b v${BIBER_VERSION} https://github.com/plk/biber.git . && \
    perl ./Build.PL && \
    ./Build installdeps && \
    ./Build install
RUN cd ./dist/linux_$(uname -a | awk '{print $(NF-1)}') && \
    chmod +x build.sh && \
    ./build.sh && \
    mv biber-linux* /tmp/biber


FROM debian:bookworm-slim AS ltexls
ARG LTEX_VERSION=15.2.0
WORKDIR /tmp/workdir
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends ca-certificates curl tar
RUN curl -o "/tmp/ltex-ls-${LTEX_VERSION}.tar.gz" -L "https://github.com/valentjn/ltex-ls/releases/download/${LTEX_VERSION}/ltex-ls-${LTEX_VERSION}.tar.gz" && \
    mkdir -p /usr/share && \
    tar -xf /tmp/ltex-ls-${LTEX_VERSION}.tar.gz -C /usr/share && \
    rm -f /tmp/ltex-ls-${LTEX_VERSION}.tar.gz && \
    mv /usr/share/ltex-ls-${LTEX_VERSION} /usr/share/ltex-ls


FROM ghcr.io/willfantom/devcontainer:latest-debian
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends \
    cpanminus \
    default-jre \
    gcc \
    git \
    inkscape \
    libc6-dev \
    make \
    perl \
    tar \
    wget
# TEXLIVE
WORKDIR /tmp/texlive
ARG TEX_SCHEME=small
RUN wget -qO- https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | tar -xz --strip-components=1 && \
    perl install-tl --paper=a4 --scheme=${TEX_SCHEME} --no-doc-install --no-src-install --texdir=/usr/local/texlive --no-interaction && \
    rm -rf /usr/local/texlive/*.log /usr/local/texlive/texmf-var/web2c/*.log /usr/local/texlive/tlpkg/texlive.tlpdb.main.*
ENV PATH ${PATH}:/usr/local/texlive/bin/x86_64-linux:/usr/local/texlive/bin/aarch64-linux
# LATEXINDENT & LATEXMK
RUN cpanm -n -q Log::Log4perl && \
    cpanm -n -q XString && \
    cpanm -n -q Log::Dispatch::File && \
    cpanm -n -q YAML::Tiny && \
    cpanm -n -q File::HomeDir && \
    cpanm -n -q Unicode::GCString && \
    cpanm -n -q Encode
RUN tlmgr install latexindent latexmk && texhash
# LTEX-LS
COPY --from=ltexls /usr/share/ltex-ls /usr/share/ltex-ls
# CHKTEX
COPY --from=chktex /tmp/chktex /usr/local/bin/chktex
# BIBER
COPY --from=biber /tmp/biber /usr/local/bin/biber
# CLEANUP
WORKDIR /workspace
RUN rm -rf /tmp/texlive && \
    apt-get remove -y cpanminus make gcc libc6-dev && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
