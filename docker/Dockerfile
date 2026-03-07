FROM ubuntu:22.04

# Prevent server from asking for insallation settings
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages for yocto
RUN apt-get update -y &&                                        \
    apt-get install -y --no-install-recommends                  \
    build-essential chrpath cpio debianutils                    \
    diffstat file gawk gcc git iputils-ping libacl1             \
    liblz4-tool locales python3 python3-git python3-jinja2      \
    python3-pexpect python3-pip python3-subunit socat           \
    texinfo unzip wget xz-utils zstd

# Remove unneeded files to reduce image size
RUN rm -rf /var/lib/apt/lists/*
# Ensure that en_US.UTF-8 locale enabled
RUN locale-gen en_US.UTF-8

# Set environment variables for locale
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Insall kas to manage yocto-layers
RUN pip3 install kas

# Create a non root user to avoid issues with yocto
RUN groupadd -g 1000 yocto-group && \
    useradd -u 1000 -g yocto-group -m -s /bin/bash yocto-user

RUN mkdir -p /yocto && chown yocto-user:yocto-group /yocto

# Switch to yocto-user
USER yocto-user
WORKDIR /yocto