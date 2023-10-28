# syntax=docker/dockerfile:1.3-labs

ARG DOCKER_IMAGE_BASE_BUILD=cr.ray.io/rayproject/oss-ci-base_build
FROM $DOCKER_IMAGE_BASE_BUILD

ARG PYTHON_VERSION
ARG PYDANTIC_VERSION

# Unset dind settings; we are using the host's docker daemon.
ENV DOCKER_TLS_CERTDIR=
ENV DOCKER_HOST=
ENV DOCKER_TLS_VERIFY=
ENV DOCKER_CERT_PATH=

SHELL ["/bin/bash", "-ice"]

COPY . .

RUN <<EOF
#!/bin/bash

set -euo pipefail

# Install custom Python version if requested.
if [[ -z $PYTHON_VERSION ]]; then 
  echo Not installing custom Python version 
else 
  PYTHON=$PYTHON_VERSION ci/env/install-dependencies.sh 
fi

pip install -U torch==2.0.1 torchvision==0.15.2
pip install -U tensorflow==2.13.1 tensorflow-probability==0.21.0
pip install -U --ignore-installed \
  -c python/requirements_compiled.txt \
  -r python/requirements.txt \
  -r python/requirements/test-requirements.txt

# doc requirements
pip intall -U --ignore-installed \  
  -c python/requirements_compiled.txt \
  -r python/requirements/ml/data-requirements.txt 
pip install datasets=2.14.0 transformers==4.30.2

git clone https://github.com/wg/wrk.git /tmp/wrk && pushd /tmp/wrk && make -j && sudo cp wrk /usr/local/bin && popd

# Install custom Pydantic version if requested.
if [[ -z $PYDANTIC_VERSION ]]; then 
  echo Not installing custom Pydantic version 
else 
  pip install -U pydantic==$PYDANTIC_VERSION
fi

EOF