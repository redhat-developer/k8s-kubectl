FROM alpine

MAINTAINER Kevin McDermott <bigkevmcd@gmail.com>

ENV KUBE_LATEST_VERSION="v1.16.3"

RUN apk add --update ca-certificates \
 && apk add --update -t deps curl bash git openssh \
 && apk add --update bash git openssh \
 && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl \
 && apk del --purge deps \
 && rm /var/cache/apk/*

ENTRYPOINT ["kubectl"]
CMD ["help"]
