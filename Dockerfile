FROM registry.fedoraproject.org/fedora-minimal

ARG HUGO_VERSION

VOLUME /site
WORKDIR /site

# Required when running htmlproofer
ENV LANG=C.UTF-8

# Install dependencies needed for hugo
RUN microdnf -y install tar shadow-utils git nodejs

# Install dependencies needed for htmlproofer
RUN microdnf -y install ruby ruby-devel gcc redhat-rpm-config

RUN microdnf clean all

# Download, untar, and install Hugo
ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz /hugo.tar.gz
RUN tar xzvf /hugo.tar.gz -C / \
 && rm /hugo.tar.gz \
 && mv /hugo /usr/bin/hugo

# Stuff for docsy
RUN npm -g -D install postcss postcss-cli autoprefixer

# Install html-proofer
RUN gem install html-proofer

# Confirm htmlproofer binary is available and show its version
RUN htmlproofer --version

# Confirm hugo binary is available and show its version
RUN hugo version
