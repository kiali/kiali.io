FROM asciidoctor/docker-asciidoctor:latest

ARG HUGO_VERSION

ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz /hugo.tar.gz
RUN tar -zxvf /hugo.tar.gz -C /

RUN addgroup -g 777 hugo && adduser -u 777 -G hugo -D hugo
USER hugo
RUN ["/hugo", "version"]

