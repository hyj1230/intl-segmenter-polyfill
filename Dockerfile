FROM surferseo/emsdk
RUN sed -i "s/deb.debian.org/archive.debian.org/g" /etc/apt/sources.list && \
    sed -i "s/security.debian.org/archive.debian.org/g" /etc/apt/sources.list && \
    sed -i "/buster-updates/d" /etc/apt/sources.list && \
    echo "Acquire::Check-Valid-Until \"false\";" > /etc/apt/apt.conf.d/99no-check-valid-until
RUN apt-get update && apt-get install -y git

WORKDIR /
RUN git clone --filter=tree:0 --no-checkout http://gh.dpik.top/https://github.com/unicode-org/icu /icu && \
    cd /icu && \
    git fetch --depth 1 origin 21d1eb0f306e1141c10931e914dfc038c06121da && \
    git checkout FETCH_HEAD
RUN mv /icu/icu4c /icu/icu

COPY ./build /build
WORKDIR /build

# for `source /emsdk/emsdk_env.sh` to work
SHELL ["/bin/bash", "-c"]

RUN cp /build/icu.py /emsdk/emscripten/master/tools/ports
RUN mkdir -p /artifacts
RUN source /emsdk/emsdk_env.sh; EMCC_LOCAL_PORTS="icu=/icu" emcc break_iterator.c -s USE_ICU=1 -o /artifacts/break_iterator.wasm  -s EXPORTED_FUNCTIONS='["_main", "_break_iterator", "_utf8_break_iterator", "_malloc", "_free"]' -s ERROR_ON_UNDEFINED_SYMBOLS=0
