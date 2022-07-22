FROM registry.redhat.io/openshift4/ose-cli

ENTRYPOINT ["kubectl"]
CMD ["help"]
