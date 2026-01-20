#!/usr/bin/env bats

load _helpers

#--------------------------------------------------------------------
# Redundancy Zones Warning

@test "notes: warns when redundancyZones enabled without topologySpreadConstraints" {
  cd `chart_dir`
  local result=$(helm install test . \
      --dry-run \
      --set 'server.ha.enabled=true' \
      --set 'server.ha.raft.enabled=true' \
      --set 'server.ha.raft.redundancyZones.enabled=true' \
      --set-string 'server.ha.raft.config=storage "raft" { path = "/vault/data" autopilot_redundancy_zone = "VAULT_REDUNDANCY_ZONE" } service_registration "kubernetes" {}' \
      2>&1 | tee /dev/stderr)

  [[ "${result}" == *"WARNING: Redundancy Zones Enabled Without topologySpreadConstraints"* ]]
  [[ "${result}" == *"server.ha.raft.redundancyZones.enabled=true"* ]]
  [[ "${result}" == *"topologySpreadConstraints"* ]]
}

@test "notes: no warning when redundancyZones enabled with topologySpreadConstraints" {
  cd `chart_dir`
  local result=$(helm install test . \
      --dry-run \
      --set 'server.ha.enabled=true' \
      --set 'server.ha.raft.enabled=true' \
      --set 'server.ha.raft.redundancyZones.enabled=true' \
      --set 'server.topologySpreadConstraints[0].maxSkew=1' \
      --set 'server.topologySpreadConstraints[0].topologyKey=topology.kubernetes.io/zone' \
      --set 'server.topologySpreadConstraints[0].whenUnsatisfiable=DoNotSchedule' \
      --set-string 'server.ha.raft.config=storage "raft" { path = "/vault/data" autopilot_redundancy_zone = "VAULT_REDUNDANCY_ZONE" } service_registration "kubernetes" {}' \
      2>&1 | tee /dev/stderr)

  [[ "${result}" != *"WARNING: Redundancy Zones Enabled Without topologySpreadConstraints"* ]]
}

@test "notes: no warning when redundancyZones is disabled" {
  cd `chart_dir`
  local result=$(helm install test . \
      --dry-run \
      --set 'server.ha.enabled=true' \
      --set 'server.ha.raft.enabled=true' \
      --set 'server.ha.raft.redundancyZones.enabled=false' \
      2>&1 | tee /dev/stderr)

  [[ "${result}" != *"WARNING: Redundancy Zones Enabled Without topologySpreadConstraints"* ]]
}
