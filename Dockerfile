FROM registry.access.redhat.com/ubi8

# Install dependencies
RUN yum install -y git gcc gcc-c++ make lksctp-tools autoconf automake binutils gdb libtool pkgconf &&\
    export ARCH=`arch` && echo -e "\n Architecture: ${ARCH} \n"
RUN git clone https://github.com/sctp/lksctp-tools.git && cp ./lksctp-tools/src/include/netinet/sctp.h.in /usr/include/netinet/sctp.h

# Pull uperf source code
RUN git clone https://github.com/uperf/uperf.git
# Build uperf binary
RUN cd uperf && autoreconf -f -i && chmod a+x ./configure && ./configure CFLAGS="-v -march=z13 -mtune=z14" DFLAGS="-03"--target=s390x-linux-gnu --program-prefix=s390x-linux-gnu- --with-arch=s390x --prefix=/usr/bin && make && chmod a+x ./src/uperf
# Ref https://github.com/projectcalico/bird/blob/feature-ipinip/create_binaries.sh
# Ref https://gist.github.com/pwhelan/55b9b17845578d54490da76949095c66
CMD ["./uperf/src/uperf"]
