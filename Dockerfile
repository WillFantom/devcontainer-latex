FROM debian:bullseye-slim AS chktex
WORKDIR /tmp/workdir
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends g++ make perl wget
ARG CHKTEX_VERSION=1.7.8
RUN wget -qO- http://download.savannah.gnu.org/releases/chktex/chktex-${CHKTEX_VERSION}.tar.gz | \
    tar -xz --strip-components=1
RUN ./configure && \
    make && \
    mv chktex /tmp && \
    rm -r *


FROM debian:bullseye-slim AS ltexls
WORKDIR /tmp/workdir
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends ca-certificates curl tar
ARG LTEX_VERSION=16.0.0
RUN curl -o "/tmp/ltex-ls-${LTEX_VERSION}.tar.gz" -L "https://github.com/valentjn/ltex-ls/releases/download/${LTEX_VERSION}/ltex-ls-${LTEX_VERSION}.tar.gz" && \
    mkdir -p /usr/share && \
    tar -xf /tmp/ltex-ls-${LTEX_VERSION}.tar.gz -C /usr/share && \
    rm -f /tmp/ltex-ls-${LTEX_VERSION}.tar.gz && \
    mv /usr/share/ltex-ls-${LTEX_VERSION} /usr/share/ltex-ls


FROM debian:bullseye-slim
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends \
    ca-certificates \
    cpanminus \
    curl \
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
# CLEANUP
RUN rm -rf /tmp/texlive && \
    apt-get remove -y cpanminus make gcc libc6-dev && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
WORKDIR /workspace
