#!/bin/bash

set -o errexit -o nounset -o pipefail

v="$(./scripts/make-version.sh tag)"

t=${IMAGE_TAG:-}
if [[ -n "$t" ]]; then
  v=$t
fi

echo "version=${v}"

image="${DOCKER_REGISTRY}/erda-telegraf:${v}"

echo "image=${image}"

#docker build -t "${image}" \
#    --label "branch=$(git rev-parse --abbrev-ref HEAD)" \
#    --label "commit=$(git rev-parse HEAD)" \
#    --label "build-time=$(date '+%Y-%m-%d %T%z')" \
#    -f "Dockerfile" .
#
#docker login -u "${DOCKER_REGISTRY_USERNAME}" -p "${DOCKER_REGISTRY_PASSWORD}" "${DOCKER_REGISTRY}"
#
#docker push "${image}"


buildctl --addr tcp://buildkitd.default.svc.cluster.local:1234 \
    --tlscacert=/.buildkit/ca.pem \
    --tlscert=/.buildkit/cert.pem \
    --tlskey=/.buildkit/key.pem \
    build \
    --frontend dockerfile.v0 \
    --opt platform=${PLATFORMS} \
    --local context=/.pipeline/container/context/telegraf \
    --local dockerfile=/.pipeline/container/context/telegraf \
    --output type=image,name=${image},push=true

echo "image=${image}" >> $METAFILE
