FROM registry.fedoraproject.org/fedora-minimal:44

VOLUME /site
WORKDIR /site

# Required when running html-proofer
ENV LANG=C.UTF-8

# Go for Hugo Modules; Node 24 + npm from Fedora (nodejs24); Ruby for htmlproofer
RUN microdnf -y install \
    git golang \
    nodejs24 nodejs24-npm \
    ruby ruby-devel gcc redhat-rpm-config \
 && microdnf clean all

# Install html-proofer and typhoeus for validate-site.sh
RUN gem install html-proofer typhoeus

# Confirm htmlproofer binary is available and show its version
RUN htmlproofer --version