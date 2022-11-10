FROM ubuntu:jammy

# These commands copy your files into the specified directory in the image
# and set that as the working location
RUN mkdir /usr/src/onionpir
COPY seal.patch /usr/src/onionpir
WORKDIR /usr/src/onionpir

# This command compiles your app using GCC, adjust for your source code
RUN apt update \
    && apt-get install -y build-essential cmake git libgmp-dev libmpfr-dev

RUN git clone https://github.com/microsoft/SEAL.git \
    && cd SEAL \
    && git checkout 3.5.1

RUN cd /usr/src/onionpir && patch -s -p0 < seal.patch \
    && cd SEAL \
    && cmake . -DCMAKE_BUILD_TYPE=Release -DSEAL_USE_MSGSL=OFF -DSEAL_USE_ZLIB=OFF \
    && make \
    && make install

RUN cd /usr/src/onionpir \
    && git clone https://github.com/micciancio/NFLlib.git \
    && cd NFLlib \
    && mkdir _build \
    && cd _build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make \
    && make install

RUN cd /usr/src/onionpir \
    && git clone https://github.com/mhmughees/Onion-PIR.git \
    && cd Onion-PIR \
    && cmake . -DCMAKE_BUILD_TYPE=Release -DNTT_AVX2=ON -DSEAL_USE_ZLIB=OFF -DSEAL_USE_MSGSL=OFF \
    && make

# This command runs your application, comment out this line to compile only
#CMD ["./myapp"]

LABEL Name=onionpir Version=0.0.1
