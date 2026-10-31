#!/usr/bin/env bash
# The stage docs/tapes/demo.tape renders on: the Mac-dressed client and the server it
# connects to, on one docker network. Everything carries the tap.demo=1 label,
# so `down` removes what a crashed render left.
#
#   docs/tapes/fixtures.sh up
#   docs/tapes/fixtures.sh down
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
net=tap-demo

function down() {
  local ids
  ids="$(docker ps -aq --filter label=tap.demo=1)"
  # shellcheck disable=SC2086 # a list of container IDs
  [[ -z "${ids}" ]] || docker rm -f ${ids} >/dev/null
  docker network rm "${net}" >/dev/null 2>&1 || true
}

function up() {
  local key i
  down
  # the Dockerfiles copy nothing, so neither build sends a context
  docker build -t tap-demo-mac - <"${dir}/mac.Dockerfile"
  docker build -t tap-demo-server - <"${dir}/server.Dockerfile"
  docker network create "${net}" >/dev/null
  key="$(docker run --rm tap-demo-mac cat .ssh/id_ed25519.pub)"
  docker run -d --rm --name web-prod --hostname web-prod --network "${net}" \
    --label tap.demo=1 -e PUBKEY="${key}" tap-demo-server >/dev/null
  docker run -d --rm --name tap-demo-mac --hostname Mayas-MacBook-Pro \
    --network "${net}" --label tap.demo=1 tap-demo-mac >/dev/null
  for i in $(seq 30)
  do
    docker exec tap-demo-mac ssh -o BatchMode=yes web-prod true 2>/dev/null && return 0
    sleep 1
  done
  echo "fixtures.sh: sshd on web-prod never answered after ${i} tries" >&2
  docker logs web-prod >&2
  return 1
}

case "${1:-}" in
  up) up ;;
  down) down ;;
  *)
    echo "usage: fixtures.sh up | down" >&2
    exit 1
    ;;
esac
