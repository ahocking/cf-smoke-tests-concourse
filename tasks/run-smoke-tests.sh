#!/bin/bash

set -e

INTEGRATION_CONFIG=$(cat <<-EOF
{
  "suite_name"                      : "CF_SMOKE_TESTS",
  "api"                             : "${PCF_API_DOMAIN}",
  "apps_domain"                     : "${SMOKETEST_APP_DOMAIN}",
  "user"                            : "${PCF_SMOKETEST_USER}",
  "password"                        : "${PCF_SMOKETEST_PASSWORD}",
  "org"                             : "CF-SMOKE-ORG",
  "space"                           : "CF-SMOKE-SPACE",
  "cleanup"                         : true,
  "use_existing_org"                : false,
  "use_existing_space"              : false,
  "logging_app"                     : "",
  "runtime_app"                     : "",
  "enable_windows_tests"            : false,
  "enable_etcd_cluster_check_tests" : false,
  "etcd_ip_address"                 : "",
  "backend"                         : "diego",
  "isolation_segment_name"          : "is1",
  "isolation_segment_domain"        : "is1.bosh-lite.com",
  "enable_isolation_segment_tests"  : false
}
EOF
)

echo $INTEGRATION_CONFIG > integration_config.json


export CONFIG=$(`pwd`/integration_config.json)
echo "Using CONFIG=$CONFIG"


# Downloading CF CLI.
# This is a static dependency and really should be part of the Docker image.
apt update
apt install -y curl
curl -L 'https://cli.run.pivotal.io/stable?release=linux64-binary&version=6.21.1' | tar -zx -C /usr/local/bin


if [[ -z "$GOPATH" ]]; then
  echo "GOPATH not specified"
  exit 1
fi

mkdir -p $GOPATH/src/github.com/cloudfoundry
ln -s `pwd`/cf-smoke-tests $GOPATH/src/github.com/cloudfoundry/cf-smoke-tests

pushd $GOPATH/src/github.com/cloudfoundry/cf-smoke-tests
  ./bin/test -v
popd
