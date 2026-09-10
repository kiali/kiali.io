#!/bin/bash
##############################################################################
# ossm-multicluster-tutorial.sh
#
# Automates the full OSSM MultiCluster on OpenShift tutorial (Guides 1-4):
#   Guide 1: Hub/Spoke — ACM, OSSM 3, Kiali, demo apps
#   Guide 2: Multi-Primary Mesh — second spoke, East-West gateways
#   Guide 3: Dashboards and Tracing — Perses, Tempo
#   Guide 4: Health Status Alerts — kiali_health_status, NetObserv
#
# Usage:
#   ./ossm-multicluster-tutorial.sh [options] <install|uninstall>
#
# Options:
#   --hub-context <ctx>         Hub cluster context (default: ossm-kiali-hub)
#   --spoke-context <ctx>       Spoke cluster 1 context (default: ossm-kiali-spoke)
#   --spoke-two-context <ctx>   Spoke cluster 2 context (default: ossm-kiali-spoke-two)
#   --guides <list>             Comma-separated guide numbers to run (default: 1,2,3,4)
#   --istio-version <ver>       Istio version to install (default: 1.30.1)
#
# Install: executes all phases sequentially, validating each before proceeding.
# Uninstall: removes everything in reverse order (guide 4 -> 1), ignoring failures.
#
# This script is idempotent for both install and uninstall -- it is safe to
# re-run at any point without causing errors.
##############################################################################

set -euo pipefail

# =============================================================================
# Utility functions
# =============================================================================

info()  { echo "[INFO]  $(date '+%H:%M:%S') $*"; }
warn()  { echo "[WARN]  $(date '+%H:%M:%S') $*" >&2; }
error() { echo "[ERROR] $(date '+%H:%M:%S') $*" >&2; exit 1; }

# Polls a command until it succeeds or times out (default: 1800s / 30 minutes).
# Usage: wait_for "description" <timeout_seconds> <command...>
wait_for() {
  local desc="$1"; shift
  local timeout="$1"; shift
  local interval=15
  local elapsed=0

  info "Waiting for: ${desc} (timeout: ${timeout}s)"
  while true; do
    if eval "$@" &>/dev/null; then
      info "OK: ${desc}"
      return 0
    fi
    elapsed=$((elapsed + interval))
    if [ "${elapsed}" -ge "${timeout}" ]; then
      error "TIMEOUT after ${timeout}s waiting for: ${desc}"
    fi
    echo "  ...still waiting (${elapsed}s elapsed)"
    sleep "${interval}"
  done
}

# =============================================================================
# UWM helper functions
# =============================================================================

# Safely enable User Workload Monitoring without clobbering unrelated monitoring
# settings. When we create the ConfigMap from scratch we label it so disable_uwm
# knows it is safe to remove on cleanup. When it already exists we merge the
# enableUserWorkload key into the existing config.yaml rather than replacing it.
enable_uwm() {
  local context=$1
  if oc --context="${context}" get configmap cluster-monitoring-config \
      -n openshift-monitoring &>/dev/null 2>&1; then
    local existing_cfg
    existing_cfg=$(oc --context="${context}" get configmap cluster-monitoring-config \
      -n openshift-monitoring -o jsonpath='{.data.config\.yaml}' 2>/dev/null || true)
    if echo "${existing_cfg}" | grep -q "enableUserWorkload:"; then
      # Key already present — overwrite only that value, preserve everything else
      oc --context="${context}" get configmap cluster-monitoring-config \
        -n openshift-monitoring -o json \
        | jq '.data["config.yaml"] |= sub("enableUserWorkload:\\s*\\w+"; "enableUserWorkload: true")' \
        | oc --context="${context}" apply -f -
    else
      # Key absent — append it without touching other keys.
      # Use // "" to tolerate a ConfigMap where data or data["config.yaml"] is null.
      oc --context="${context}" get configmap cluster-monitoring-config \
        -n openshift-monitoring -o json \
        | jq '.data["config.yaml"] = ((.data["config.yaml"] // "") + "\nenableUserWorkload: true\n")' \
        | oc --context="${context}" apply -f -
    fi
  else
    # ConfigMap does not exist — create it and label it as tutorial-owned so
    # disable_uwm can safely remove it on cleanup.
    oc --context="${context}" create configmap cluster-monitoring-config \
      -n openshift-monitoring \
      --from-literal=config.yaml="enableUserWorkload: true"
    oc --context="${context}" label configmap cluster-monitoring-config \
      -n openshift-monitoring kiali.io/tutorial-owned=true
  fi
}

# Remove the cluster-monitoring-config ConfigMap only when enable_uwm created
# it fresh (i.e. it carries kiali.io/tutorial-owned=true). Pre-existing
# ConfigMaps — and those on clusters the tutorial never touched — are preserved.
disable_uwm() {
  local context=$1
  local owned
  owned=$(oc --context="${context}" get configmap cluster-monitoring-config \
    -n openshift-monitoring \
    -o jsonpath='{.metadata.labels.kiali\.io/tutorial-owned}' 2>/dev/null || true)
  if [ "${owned}" = "true" ]; then
    oc --context="${context}" delete configmap cluster-monitoring-config \
      -n openshift-monitoring --ignore-not-found
  fi
}

# =============================================================================
# MCOA helper functions
# =============================================================================

# Install the full COO product on a cluster context. MCOA can also register the
# ScrapeConfig CRD, so use the COO Subscription rather than that CRD to detect
# an existing COO installation.
install_coo() {
  local ctx="$1" coo_info coo_ns coo_csv
  coo_info=$(oc --context="${ctx}" get subscriptions.operators.coreos.com -A -o json 2>/dev/null | \
    jq -r '[.items[] | select(.spec.name == "cluster-observability-operator")][0] |
      select(. != null) | [.metadata.namespace, (.status.installedCSV // "")] | @tsv' 2>/dev/null || true)
  if [ -n "${coo_info}" ]; then
    IFS=$'\t' read -r coo_ns coo_csv <<< "${coo_info}"
    info "COO already installed on ${ctx} — skipping"
  else
    info "Installing COO on ${ctx}"
    oc --context="${ctx}" apply -f - <<'EOF'
apiVersion: v1
kind: Namespace
metadata:
  labels:
    openshift.io/cluster-monitoring: "true"
  name: openshift-cluster-observability-operator
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: cluster-observability-operator
  namespace: openshift-cluster-observability-operator
spec: {}
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: cluster-observability-operator
  namespace: openshift-cluster-observability-operator
spec:
  channel: stable
  installPlanApproval: Automatic
  name: cluster-observability-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
  fi
  wait_for "COO Subscription installed on ${ctx}" "${TIMEOUT}" \
    "[ -n \"\$(oc --context=${ctx} get subscriptions.operators.coreos.com -A -o json 2>/dev/null | jq -r '[.items[] | select(.spec.name == \"cluster-observability-operator\")][0].status.installedCSV // empty')\" ]"
}

# Enable MCOA platform and user-workload capabilities on the MCO CR (hub only).
# Idempotent — patches in place; MCOA waits for the ScrapeConfig CRD and a
# populated placement before returning.
enable_mcoa_capabilities() {
  info "Enabling MCOA platform + user-workload capabilities on hub"
  oc --context="${HUB_CTX}" patch mco observability --type=merge -p \
    '{"spec":{"capabilities":{"platform":{"metrics":{"default":{"enabled":true}}},"userWorkloads":{"metrics":{"default":{"enabled":true}}}}}}'
  wait_for "ScrapeConfig CRD and MCOA placement populated" "${TIMEOUT}" \
    "oc --context=${HUB_CTX} get crd scrapeconfigs.monitoring.rhobs && \
     [ \"\$(oc --context=${HUB_CTX} get clustermanagementaddon multicluster-observability-addon \
         -o json 2>/dev/null | jq '(.spec.installStrategy.placements // []) | length' 2>/dev/null || echo 0)\" -gt 0 ]"
}

# Load MCOA placement into MCOA_PLACEMENT_NAME / MCOA_PLACEMENT_NS globals.
# Fails if there are multiple placements and neither var is set.
MCOA_PLACEMENT_NAME=""
MCOA_PLACEMENT_NS=""
select_mcoa_placement() {
  local addon_json count
  addon_json=$(oc --context="${HUB_CTX}" get clustermanagementaddon \
    multicluster-observability-addon -o json)
  count=$(echo "${addon_json}" | jq '(.spec.installStrategy.placements // []) | length')
  [ "${count}" -gt 0 ] || error "MCOA has no populated placements"
  if [ -z "${MCOA_PLACEMENT_NAME}" ]; then
    [ "${count}" -eq 1 ] || error "MCOA has ${count} placements; set MCOA_PLACEMENT_NAME and MCOA_PLACEMENT_NS"
    MCOA_PLACEMENT_NAME=$(echo "${addon_json}" | jq -r '.spec.installStrategy.placements[0].name')
    MCOA_PLACEMENT_NS=$(echo "${addon_json}" | jq -r '.spec.installStrategy.placements[0].namespace')
    info "Using MCOA placement: ${MCOA_PLACEMENT_NS}/${MCOA_PLACEMENT_NAME}"
  fi
}

# Idempotent add of an MCOA configuration resource reference to the placement.
# Usage: add_mcoa_ref <group> <resource> <name>
add_mcoa_ref() {
  local group="$1" resource="$2" name="$3"
  local obs_ns="open-cluster-management-observability"
  local addon_json exists idx configs op path
  addon_json=$(oc --context="${HUB_CTX}" get clustermanagementaddon \
    multicluster-observability-addon -o json)
  exists=$(echo "${addon_json}" | jq -r \
    --arg g "${group}" --arg r "${resource}" --arg n "${name}" --arg ns "${obs_ns}" \
    --arg pn "${MCOA_PLACEMENT_NAME}" --arg pns "${MCOA_PLACEMENT_NS}" \
    '[.spec.installStrategy.placements[] |
      select(.name == $pn and .namespace == $pns) |
      .configs[]? |
      select(.group == $g and .resource == $r and .name == $n and .namespace == $ns)] | length')
  if [ "${exists}" -eq 0 ]; then
    idx=$(echo "${addon_json}" | jq -r \
      --arg pn "${MCOA_PLACEMENT_NAME}" --arg pns "${MCOA_PLACEMENT_NS}" \
      '.spec.installStrategy.placements | to_entries[] |
        select(.value.name == $pn and .value.namespace == $pns) | .key')
    configs=$(echo "${addon_json}" | jq -r \
      --argjson i "${idx}" '.spec.installStrategy.placements[$i].configs | type == "array"')
    if [ "${configs}" = true ]; then
      op="add"; path="/spec/installStrategy/placements/${idx}/configs/-"
    else
      op="add"; path="/spec/installStrategy/placements/${idx}/configs"
    fi
    oc --context="${HUB_CTX}" patch clustermanagementaddon multicluster-observability-addon \
      --type=json -p="[{\"op\":\"${op}\",\"path\":\"${path}\",
        \"value\":{\"group\":\"${group}\",\"resource\":\"${resource}\",
                   \"name\":\"${name}\",\"namespace\":\"${obs_ns}\"}}]"
    info "Added ${resource}/${name} to placement ${MCOA_PLACEMENT_NS}/${MCOA_PLACEMENT_NAME}"
  fi
}

# Idempotent removal of an MCOA configuration resource reference from the placement.
# Usage: remove_mcoa_ref <group> <resource> <name>
remove_mcoa_ref() {
  local group="$1" resource="$2" name="$3"
  local obs_ns="open-cluster-management-observability"
  local addon_json patch
  addon_json=$(oc --context="${HUB_CTX}" get clustermanagementaddon \
    multicluster-observability-addon -o json 2>/dev/null) || return 0
  patch=$(echo "${addon_json}" | jq -c \
    --arg g "${group}" --arg r "${resource}" --arg n "${name}" --arg ns "${obs_ns}" \
    '[(.spec.installStrategy.placements // []) | to_entries[] as $p |
      ($p.value.configs // []) | to_entries[] |
      select(.value.group == $g and .value.resource == $r and
             .value.name == $n and .value.namespace == $ns) |
      {op:"remove",
       path:("/spec/installStrategy/placements/"+($p.key|tostring)+"/configs/"+(.key|tostring))}]
    | sort_by(.path) | reverse')
  [ "${patch}" = "[]" ] || oc --context="${HUB_CTX}" patch clustermanagementaddon \
    multicluster-observability-addon --type=json -p="${patch}"
}

# Uninstall COO from a given context. Dynamically discovers the subscription
# namespace — does not assume openshift-operators or any other fixed namespace.
# Removes the subscription, CSV, namespace, and COO-labeled CRDs. Do not delete
# every .monitoring.rhobs CRD: MCOA can own APIs in that group independently.
uninstall_coo() {
  local ctx="$1"
  local coo_info coo_ns coo_sub coo_csv
  coo_info=$(oc --context="${ctx}" get subscriptions.operators.coreos.com -A -o json 2>/dev/null | \
    jq -r '[.items[] | select(.spec.name == "cluster-observability-operator")][0] |
      select(. != null) | [.metadata.namespace, .metadata.name, (.status.installedCSV // "")] | @tsv' \
    2>/dev/null || true)
  if [ -n "${coo_info}" ]; then
    IFS=$'\t' read -r coo_ns coo_sub coo_csv <<< "${coo_info}"
    oc --context="${ctx}" delete subscription.operators.coreos.com \
      "${coo_sub}" -n "${coo_ns}" --ignore-not-found
    [ -z "${coo_csv}" ] || oc --context="${ctx}" delete csv \
      "${coo_csv}" -n "${coo_ns}" --ignore-not-found
    oc --context="${ctx}" delete namespace "${coo_ns}" --ignore-not-found --wait=false
    wait_for "COO namespace ${coo_ns} removed from ${ctx}" 120 \
      "! oc --context=${ctx} get namespace ${coo_ns} &>/dev/null"
  else
    info "No full COO Subscription on ${ctx} — leaving MCOA-managed monitoring.rhobs APIs intact"
    return 0
  fi
  oc --context="${ctx}" delete crd \
    -l 'operators.coreos.com/cluster-observability-operator.openshift-cluster-observability' \
    --ignore-not-found 2>/dev/null || true
  info "COO uninstalled from ${ctx}"
}

# Create all hub-side MCOA configuration resources for Istio federation (9 objects):
# 1 shared user-workload ScrapeConfig + 4 platform ScrapeConfigs + 4 PrometheusRules.
# Requires MCOA_PLACEMENT_NAME / MCOA_PLACEMENT_NS to be set.
create_istio_federation_resources() {
  local obs_ns="open-cluster-management-observability"

  # Shared user-workload ScrapeConfig
  oc --context="${HUB_CTX}" apply -f - <<'EOF'
apiVersion: monitoring.rhobs/v1alpha1
kind: ScrapeConfig
metadata:
  labels:
    app.kubernetes.io/component: user-workload-metrics-collector
    app.kubernetes.io/managed-by: kiali-mcoa-federation
  name: kiali-istio-federation
  namespace: open-cluster-management-observability
spec:
  honorLabels: true
  jobName: kiali-istio-federation
  metricRelabelings:
  - action: replace
    regex: 'workload:(.*)'
    replacement: '${1}'
    sourceLabels: [__name__]
    targetLabel: __name__
  metricsPath: /federate
  params:
    match[]:
    - '{__name__=~"workload:istio_requests_total"}'
    - '{__name__=~"workload:istio_request_bytes_(bucket|count|sum)"}'
    - '{__name__=~"workload:istio_request_duration_milliseconds_(bucket|count|sum)"}'
    - '{__name__=~"workload:istio_request_messages_total"}'
    - '{__name__=~"workload:istio_response_bytes_(bucket|count|sum)"}'
    - '{__name__=~"workload:istio_response_messages_total"}'
    - '{__name__=~"workload:istio_tcp_connections_(opened|closed)_total"}'
    - '{__name__=~"workload:istio_tcp_(received|sent)_bytes_total"}'
    - '{__name__=~"istio_build"}'
    - '{__name__=~"process_cpu_seconds_total"}'
    - '{__name__=~"process_resident_memory_bytes"}'
    - '{__name__=~"pilot_info"}'
    - '{__name__=~"pilot_proxy_convergence_time_(sum|count)"}'
    - '{__name__=~"pilot_services"}'
    - '{__name__=~"pilot_xds$"}'
    - '{__name__=~"pilot_xds_pushes"}'
    - '{__name__=~"workload_manager_active_proxy_count"}'
    - '{__name__=~"envoy_cluster_upstream_cx_active"}'
    - '{__name__=~"envoy_cluster_upstream_rq_total"}'
    - '{__name__=~"envoy_listener_downstream_cx_active"}'
    - '{__name__=~"envoy_listener_http_downstream_rq"}'
    - '{__name__=~"envoy_server_memory_allocated"}'
    - '{__name__=~"envoy_server_memory_heap_size"}'
    - '{__name__=~"envoy_server_uptime"}'
EOF
  add_mcoa_ref monitoring.rhobs scrapeconfigs kiali-istio-federation

  # Platform ScrapeConfigs (one per namespace)
  local ns
  for ns in istio-system ztunnel ambient-demo bookinfo; do
    oc --context="${HUB_CTX}" apply -f - <<EOF
apiVersion: monitoring.rhobs/v1alpha1
kind: ScrapeConfig
metadata:
  labels:
    app.kubernetes.io/component: platform-metrics-collector
    app.kubernetes.io/managed-by: kiali-mcoa-federation
  name: kiali-istio-platform-federation-${ns}
  namespace: ${obs_ns}
spec:
  jobName: kiali-istio-platform-federation-${ns}
  metricsPath: /federate
  params:
    match[]:
    - '{__name__=~"container_cpu_usage_seconds_total|container_memory_working_set_bytes",namespace="${ns}"}'
EOF
    add_mcoa_ref monitoring.rhobs scrapeconfigs "kiali-istio-platform-federation-${ns}"
  done

  # Aggregation PrometheusRules (one per namespace)
  for ns in istio-system ztunnel ambient-demo bookinfo; do
    oc --context="${HUB_CTX}" apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  annotations:
    observability.open-cluster-management.io/target-namespace: ${ns}
  labels:
    app.kubernetes.io/component: user-workload-metrics-collector
    app.kubernetes.io/managed-by: kiali-mcoa-federation
    openshift.io/prometheus-rule-evaluation-scope: leaf-prometheus
  name: kiali-istio-aggregation-${ns}
  namespace: ${obs_ns}
spec:
  groups:
  - interval: 30s
    name: istio.workload-aggregation
    rules:
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_requests_total)
      record: workload:istio_requests_total
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_messages_total)
      record: workload:istio_request_messages_total
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_response_messages_total)
      record: workload:istio_response_messages_total
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_tcp_sent_bytes_total)
      record: workload:istio_tcp_sent_bytes_total
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_tcp_received_bytes_total)
      record: workload:istio_tcp_received_bytes_total
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_tcp_connections_opened_total)
      record: workload:istio_tcp_connections_opened_total
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_tcp_connections_closed_total)
      record: workload:istio_tcp_connections_closed_total
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_duration_milliseconds_bucket)
      record: workload:istio_request_duration_milliseconds_bucket
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_duration_milliseconds_sum)
      record: workload:istio_request_duration_milliseconds_sum
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_duration_milliseconds_count)
      record: workload:istio_request_duration_milliseconds_count
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_bytes_bucket)
      record: workload:istio_request_bytes_bucket
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_bytes_sum)
      record: workload:istio_request_bytes_sum
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_bytes_count)
      record: workload:istio_request_bytes_count
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_response_bytes_bucket)
      record: workload:istio_response_bytes_bucket
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_response_bytes_sum)
      record: workload:istio_response_bytes_sum
    - expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_response_bytes_count)
      record: workload:istio_response_bytes_count
EOF
    add_mcoa_ref monitoring.coreos.com prometheusrules "kiali-istio-aggregation-${ns}"
  done

  info "MCOA Istio federation resources created and registered with placement"
}

# Create MCOA health federation resources for kiali_health_status (hub only).
# Requires MCOA_PLACEMENT_NAME / MCOA_PLACEMENT_NS to be set.
create_kiali_health_federation_resources() {
  local obs_ns="open-cluster-management-observability"

  oc --context="${HUB_CTX}" apply -f - <<'EOF'
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  annotations:
    observability.open-cluster-management.io/target-namespace: istio-system
  labels:
    app.kubernetes.io/component: user-workload-metrics-collector
    app.kubernetes.io/managed-by: kiali-mcoa-federation
    openshift.io/prometheus-rule-evaluation-scope: leaf-prometheus
  name: kiali-health-aggregation
  namespace: open-cluster-management-observability
spec:
  groups:
  - interval: 30s
    name: kiali.aggregation
    rules:
    - expr: max without (pod, pod_template_hash, instance, namespace, job, node) (kiali_health_status)
      record: kiali:kiali_health_status
EOF
  add_mcoa_ref monitoring.coreos.com prometheusrules kiali-health-aggregation

  oc --context="${HUB_CTX}" apply -f - <<'EOF'
apiVersion: monitoring.rhobs/v1alpha1
kind: ScrapeConfig
metadata:
  labels:
    app.kubernetes.io/component: user-workload-metrics-collector
    app.kubernetes.io/managed-by: kiali-mcoa-federation
  name: kiali-health-federation
  namespace: open-cluster-management-observability
spec:
  honorLabels: true
  jobName: kiali-health-federation
  metricRelabelings:
  - action: replace
    regex: 'kiali:(.*)'
    replacement: '${1}'
    sourceLabels: [__name__]
    targetLabel: __name__
  metricsPath: /federate
  params:
    match[]:
    - '{__name__="kiali:kiali_health_status"}'
EOF
  add_mcoa_ref monitoring.rhobs scrapeconfigs kiali-health-federation

  info "MCOA kiali_health_status federation resources created"
}

# =============================================================================
# Configuration
# =============================================================================

HUB_CTX="${HUB_CTX:-ossm-kiali-hub}"
SPOKE_CTX="${SPOKE_CTX:-ossm-kiali-spoke}"
SPOKE_TWO_CTX="${SPOKE_TWO_CTX:-ossm-kiali-spoke-two}"

SPOKE_CLUSTER_NAME="spoke"
SPOKE_TWO_CLUSTER_NAME="spoke-two"
ISTIO_VERSION="${ISTIO_VERSION:-1.30.1}"
MESH_ID="mesh1"
MINIO_ACCESS_KEY="minio"
MINIO_SECRET_KEY="minio123"
SPOKE_NETWORK="network1"
SPOKE_TWO_NETWORK="network2"
TEMPO_NAMESPACE="tempo"
TEMPO_STACK_NAME="istio"
TEMPO_TENANT="mesh1"

GUIDES="1,2,3,4"

TIMEOUT=1800

TMP_DIR="/tmp/ossm-tutorial"

# Returns 0 if the given guide number is in the GUIDES list
run_guide() {
  [[ ",${GUIDES}," == *",$1,"* ]]
}

# =============================================================================
# Guide 1: Hub/Spoke
# =============================================================================

guide1_phase1_acm_hub() {
  info "=== Guide 1 Phase 1: ACM on the Hub Cluster ==="

  local ACM_CHANNEL
  ACM_CHANNEL=$(oc --context="${HUB_CTX}" get packagemanifest advanced-cluster-management \
    -n openshift-marketplace \
    -o jsonpath='{.status.channels[*].name}' | \
    tr ' ' '\n' | sort -V | tail -1)
  info "Using ACM channel: ${ACM_CHANNEL}"

  oc --context="${HUB_CTX}" create namespace open-cluster-management 2>/dev/null || true

  oc --context="${HUB_CTX}" apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: open-cluster-management
  namespace: open-cluster-management
spec:
  targetNamespaces:
  - open-cluster-management
EOF

  oc --context="${HUB_CTX}" apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: acm-operator-subscription
  namespace: open-cluster-management
spec:
  sourceNamespace: openshift-marketplace
  source: redhat-operators
  channel: ${ACM_CHANNEL}
  installPlanApproval: Automatic
  name: advanced-cluster-management
EOF

  wait_for "MCH CRD established" "${TIMEOUT}" \
    "oc --context=${HUB_CTX} get crd multiclusterhubs.operator.open-cluster-management.io"

  wait_for "MCH operator pod ready" "${TIMEOUT}" \
    "oc --context=${HUB_CTX} wait pod -l name=multiclusterhub-operator -n open-cluster-management --for=condition=Ready --timeout=10s"

  oc --context="${HUB_CTX}" apply -f - <<'EOF'
apiVersion: operator.open-cluster-management.io/v1
kind: MultiClusterHub
metadata:
  name: multiclusterhub
  namespace: open-cluster-management
spec: {}
EOF

  wait_for "MultiClusterHub Running" "${TIMEOUT}" \
    "[ \"\$(oc --context=${HUB_CTX} get mch multiclusterhub -n open-cluster-management -o jsonpath='{.status.phase}')\" = 'Running' ]"

  # Enable ACM Observability
  oc --context="${HUB_CTX}" create namespace open-cluster-management-observability 2>/dev/null || true

  oc --context="${HUB_CTX}" apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio
  namespace: open-cluster-management-observability
spec:
  replicas: 1
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      containers:
      - name: minio
        image: quay.io/minio/minio:latest
        args:
        - server
        - /data
        - --console-address
        - ":9001"
        env:
        - name: MINIO_ROOT_USER
          value: "${MINIO_ACCESS_KEY}"
        - name: MINIO_ROOT_PASSWORD
          value: "${MINIO_SECRET_KEY}"
        ports:
        - containerPort: 9000
          name: api
        - containerPort: 9001
          name: console
        volumeMounts:
        - name: data
          mountPath: /data
        readinessProbe:
          httpGet:
            path: /minio/health/ready
            port: 9000
          initialDelaySeconds: 10
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /minio/health/live
            port: 9000
          initialDelaySeconds: 10
          periodSeconds: 5
      volumes:
      - name: data
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: minio
  namespace: open-cluster-management-observability
spec:
  ports:
  - port: 9000
    name: api
    targetPort: 9000
  - port: 9001
    name: console
    targetPort: 9001
  selector:
    app: minio
EOF

  wait_for "MinIO ready" "${TIMEOUT}" \
    "oc --context=${HUB_CTX} rollout status deployment/minio -n open-cluster-management-observability --timeout=10s"

  local MINIO_POD
  MINIO_POD=$(oc --context="${HUB_CTX}" get pods -n open-cluster-management-observability \
    -l app=minio -o jsonpath='{.items[0].metadata.name}')
  oc --context="${HUB_CTX}" exec -n open-cluster-management-observability "${MINIO_POD}" -- mkdir -p /data/thanos

  oc --context="${HUB_CTX}" apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: thanos-object-storage
  namespace: open-cluster-management-observability
type: Opaque
stringData:
  thanos.yaml: |
    type: s3
    config:
      bucket: thanos
      endpoint: minio.open-cluster-management-observability.svc:9000
      insecure: true
      access_key: ${MINIO_ACCESS_KEY}
      secret_key: ${MINIO_SECRET_KEY}
EOF

  oc --context="${HUB_CTX}" apply -f - <<'EOF'
apiVersion: observability.open-cluster-management.io/v1beta2
kind: MultiClusterObservability
metadata:
  name: observability
spec:
  capabilities:
    platform:
      metrics:
        default:
          enabled: true
    userWorkloads:
      metrics:
        default:
          enabled: true
  observabilityAddonSpec: {}
  storageConfig:
    metricObjectStorage:
      name: thanos-object-storage
      key: thanos.yaml
    alertmanagerStorageSize: 1Gi
    compactStorageSize: 10Gi
    receiveStorageSize: 10Gi
    ruleStorageSize: 1Gi
    storeStorageSize: 10Gi
  advanced:
    retentionConfig:
      retentionInLocal: 24h
      retentionResolution1h: 365d
      retentionResolution5m: 365d
      retentionResolutionRaw: 365d
    alertmanager:
      replicas: 1
      resources:
        requests:
          cpu: 20m
          memory: 64Mi
    compact:
      resources:
        requests:
          cpu: 50m
          memory: 128Mi
    grafana:
      replicas: 1
      resources:
        requests:
          cpu: 20m
          memory: 64Mi
    observatoriumAPI:
      replicas: 1
      resources:
        requests:
          cpu: 20m
          memory: 64Mi
    query:
      replicas: 1
      resources:
        requests:
          cpu: 50m
          memory: 128Mi
    queryFrontend:
      replicas: 1
      resources:
        requests:
          cpu: 50m
          memory: 64Mi
    queryFrontendMemcached:
      replicas: 1
      resources:
        requests:
          cpu: 20m
          memory: 64Mi
    rbacQueryProxy:
      replicas: 1
      resources:
        requests:
          cpu: 20m
          memory: 64Mi
    receive:
      resources:
        requests:
          cpu: 50m
          memory: 128Mi
    rule:
      replicas: 1
      resources:
        requests:
          cpu: 50m
          memory: 128Mi
    store:
      replicas: 1
      resources:
        requests:
          cpu: 50m
          memory: 128Mi
    storeMemcached:
      replicas: 1
      resources:
        requests:
          cpu: 20m
          memory: 64Mi
EOF

  wait_for "MultiClusterObservability Ready" "${TIMEOUT}" \
    "[ \"\$(oc --context=${HUB_CTX} get mco observability -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}' 2>/dev/null)\" = 'True' ]"

  # MCOA owns its ScrapeConfig API and managed-cluster Prometheus components.
  enable_mcoa_capabilities
  select_mcoa_placement

  # Create hub-side MCOA configuration resources for Istio federation
  create_istio_federation_resources
}

guide1_phase2_import_spoke() {
  info "=== Guide 1 Phase 2: Import Spoke into ACM ==="

  oc --context="${HUB_CTX}" create namespace "${SPOKE_CLUSTER_NAME}" 2>/dev/null || true

  oc --context="${HUB_CTX}" apply -f - <<EOF
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: ${SPOKE_CLUSTER_NAME}
  labels:
    cloud: auto-detect
    vendor: auto-detect
spec:
  hubAcceptsClient: true
EOF

  oc config view --context="${SPOKE_CTX}" --minify --flatten \
    > "${TMP_DIR}/spoke-kubeconfig.yaml"

  oc --context="${HUB_CTX}" create secret generic auto-import-secret \
    -n "${SPOKE_CLUSTER_NAME}" \
    --from-file=kubeconfig="${TMP_DIR}/spoke-kubeconfig.yaml" 2>/dev/null || true

  oc --context="${HUB_CTX}" apply -f - <<EOF
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: ${SPOKE_CLUSTER_NAME}
  namespace: ${SPOKE_CLUSTER_NAME}
spec:
  applicationManager:
    enabled: true
  certPolicyController:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
EOF

  wait_for "Spoke joined and available" "${TIMEOUT}" \
    "oc --context=${HUB_CTX} get managedcluster ${SPOKE_CLUSTER_NAME} -o jsonpath='{range .status.conditions[*]}{.type}={.status} {end}' | grep -q 'ManagedClusterJoined=True' && oc --context=${HUB_CTX} get managedcluster ${SPOKE_CLUSTER_NAME} -o jsonpath='{range .status.conditions[*]}{.type}={.status} {end}' | grep -q 'ManagedClusterConditionAvailable=True'"

  rm -f "${TMP_DIR}/spoke-kubeconfig.yaml"
}

guide1_phase3_ossm3_spoke() {
  info "=== Guide 1 Phase 3: OSSM 3 on Spoke ==="

  # Enable UWM (safe merge — does not overwrite unrelated monitoring settings)
  enable_uwm "${SPOKE_CTX}"

  wait_for "UWM Prometheus ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait pod --for=condition=Ready -l app.kubernetes.io/name=prometheus -n openshift-user-workload-monitoring --timeout=10s"

  # Ensure target namespaces exist so MCOA can propagate PrometheusRules into them
  local ns
  for ns in istio-system ztunnel ambient-demo bookinfo; do
    oc --context="${SPOKE_CTX}" create namespace "${ns}" --dry-run=client -o yaml | \
      oc --context="${SPOKE_CTX}" apply -f - 2>/dev/null || true
  done

  # Install OSSM 3 Operator
  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-service-mesh-operator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: servicemeshoperator3
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

  wait_for "OSSM operator ready on spoke" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait pod --for=condition=Ready -l app.kubernetes.io/created-by=servicemeshoperator3 -n openshift-operators --timeout=10s"

  # Create namespaces
  oc --context="${SPOKE_CTX}" create namespace istio-system 2>/dev/null || true
  oc --context="${SPOKE_CTX}" create namespace istio-cni 2>/dev/null || true
  oc --context="${SPOKE_CTX}" create namespace ztunnel 2>/dev/null || true
  oc --context="${SPOKE_CTX}" label namespace ztunnel istio-discovery=enabled --overwrite

  # Generate CA certificates
  mkdir -p "${TMP_DIR}/istio-certs"
  cd "${TMP_DIR}/istio-certs"

  openssl genrsa -out root-key.pem 4096 2>/dev/null

  cat > root-ca.conf <<'CONF'
encrypt_key = no
prompt = no
utf8 = yes
default_md = sha256
default_bits = 4096
req_extensions = req_ext
x509_extensions = req_ext
distinguished_name = req_dn
[ req_ext ]
subjectKeyIdentifier = hash
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment, keyCertSign
[ req_dn ]
O = Istio
CN = Root CA
CONF

  openssl req -sha256 -new -key root-key.pem -config root-ca.conf -out root-cert.csr 2>/dev/null
  openssl x509 -req -sha256 -days 3650 -signkey root-key.pem \
    -extensions req_ext -extfile root-ca.conf -in root-cert.csr -out root-cert.pem 2>/dev/null

  cat > intermediate.conf <<'CONF'
[ req ]
encrypt_key = no
prompt = no
utf8 = yes
default_md = sha256
default_bits = 4096
req_extensions = req_ext
x509_extensions = req_ext
distinguished_name = req_dn
[ req_ext ]
subjectKeyIdentifier = hash
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment, keyCertSign
subjectAltName=@san
[ san ]
DNS.1 = istiod.istio-system.svc
[ req_dn ]
O = Istio
CN = Intermediate CA
L = spoke
CONF

  openssl genrsa -out ca-key.pem 4096 2>/dev/null
  openssl req -new -config intermediate.conf -key ca-key.pem -out cluster-ca.csr 2>/dev/null
  openssl x509 -req -sha256 -days 3650 -CA root-cert.pem -CAkey root-key.pem -CAcreateserial \
    -extensions req_ext -extfile intermediate.conf -in cluster-ca.csr -out ca-cert.pem 2>/dev/null
  cat ca-cert.pem root-cert.pem > cert-chain.pem

  cd -

  # Load CA certs
  oc --context="${SPOKE_CTX}" get secret cacerts -n istio-system &>/dev/null || \
  oc --context="${SPOKE_CTX}" create secret generic cacerts -n istio-system \
    --from-file=ca-cert.pem="${TMP_DIR}/istio-certs/ca-cert.pem" \
    --from-file=ca-key.pem="${TMP_DIR}/istio-certs/ca-key.pem" \
    --from-file=root-cert.pem="${TMP_DIR}/istio-certs/root-cert.pem" \
    --from-file=cert-chain.pem="${TMP_DIR}/istio-certs/cert-chain.pem"

  # Install IstioCNI
  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: sailoperator.io/v1
kind: IstioCNI
metadata:
  name: default
spec:
  namespace: istio-cni
  profile: openshift-ambient
  version: v${ISTIO_VERSION}
EOF

  wait_for "IstioCNI ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait istiocni default --for=condition=Ready --timeout=10s"

  # Install Istio control plane
  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: sailoperator.io/v1
kind: Istio
metadata:
  name: default
spec:
  namespace: istio-system
  profile: openshift-ambient
  updateStrategy:
    type: InPlace
  values:
    global:
      meshID: ${MESH_ID}
    meshConfig:
      discoverySelectors:
      - matchLabels:
          istio-discovery: enabled
    pilot:
      trustedZtunnelNamespace: ztunnel
  version: v${ISTIO_VERSION}
EOF

  wait_for "Istio ready on spoke" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait istio default --for=condition=Ready --timeout=10s"

  # Install ZTunnel
  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: sailoperator.io/v1
kind: ZTunnel
metadata:
  name: default
spec:
  namespace: ztunnel
  version: v${ISTIO_VERSION}
EOF

  wait_for "ZTunnel ready on spoke" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait ztunnel default --for=condition=Ready --timeout=10s"

  # Configure metrics collection
  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: istiod-monitor
  namespace: istio-system
spec:
  targetLabels:
  - app
  selector:
    matchLabels:
      istio: pilot
  endpoints:
  - port: http-monitoring
    interval: 30s
EOF

  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: ztunnel-monitor
  namespace: ztunnel
spec:
  selector:
    matchExpressions:
    - key: istio-prometheus-ignore
      operator: DoesNotExist
  podMetricsEndpoints:
  - path: /stats/prometheus
    interval: 30s
    relabelings:
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_container_name"]
      regex: "istio-proxy"
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_annotationpresent_prometheus_io_scrape"]
    - action: replace
      regex: (\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})
      replacement: '[\$2]:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - action: replace
      regex: (\d+);((([0-9]+?)(\.|$)){4})
      replacement: '\$2:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - sourceLabels: ["__meta_kubernetes_namespace"]
      action: replace
      targetLabel: namespace
    - action: replace
      replacement: "${MESH_ID}"
      targetLabel: mesh_id
EOF
}

guide1_phase4_kiali() {
  info "=== Guide 1 Phase 4: Kiali ==="

  # Extract Observatorium certs from hub
  local OBSERVATORIUM_URL
  OBSERVATORIUM_URL=$(oc --context="${HUB_CTX}" get route observatorium-api \
    -n open-cluster-management-observability \
    -o jsonpath='https://{.spec.host}/api/metrics/v1/default')
  info "Observatorium URL: ${OBSERVATORIUM_URL}"

  oc --context="${HUB_CTX}" get secret observability-grafana-certs \
    -n open-cluster-management-observability \
    -o jsonpath='{.data.tls\.crt}' | base64 -d > "${TMP_DIR}/obs-tls.crt"

  oc --context="${HUB_CTX}" get secret observability-grafana-certs \
    -n open-cluster-management-observability \
    -o jsonpath='{.data.tls\.key}' | base64 -d > "${TMP_DIR}/obs-tls.key"

  # Determine which CA signed the Observatorium route
  local HOST
  HOST=$(oc --context="${HUB_CTX}" get route observatorium-api \
    -n open-cluster-management-observability \
    -o jsonpath='{.spec.host}')

  local ISSUER
  ISSUER=$(echo | openssl s_client -connect "${HOST}:443" -servername "${HOST}" -showcerts 2>/dev/null | openssl x509 -noout -issuer)

  if echo "${ISSUER}" | grep -q "observability-server-ca-certificate"; then
    oc --context="${HUB_CTX}" get secret observability-server-ca-certs \
      -n open-cluster-management-observability \
      -o jsonpath='{.data.ca\.crt}' | base64 -d > "${TMP_DIR}/obs-server-ca.crt"
  else
    oc --context="${HUB_CTX}" get secret observability-client-ca-certs \
      -n open-cluster-management-observability \
      -o jsonpath='{.data.ca\.crt}' | base64 -d > "${TMP_DIR}/obs-server-ca.crt"
  fi

  # Create cert resources on spoke
  oc --context="${SPOKE_CTX}" create secret generic acm-observability-certs \
    -n istio-system \
    --from-file=tls.crt="${TMP_DIR}/obs-tls.crt" \
    --from-file=tls.key="${TMP_DIR}/obs-tls.key" 2>/dev/null || true

  oc --context="${SPOKE_CTX}" create configmap kiali-cabundle \
    -n istio-system \
    --from-file=additional-ca-bundle.pem="${TMP_DIR}/obs-server-ca.crt" 2>/dev/null || true

  # Install Kiali Operator
  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-ossm
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: kiali-ossm
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

  wait_for "Kiali operator ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait pod --for=condition=Ready -l app.kubernetes.io/name=kiali-operator -n openshift-operators --timeout=10s"

  # Install Kiali CR
  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: istio-system
spec:
  auth:
    strategy: openshift
    openshift:
      impersonation:
        enabled: false
  deployment:
    cluster_wide_access: true
    instance_name: kiali
    namespace: istio-system
    replicas: 1
  external_services:
    grafana:
      enabled: false
    prometheus:
      auth:
        cert_file: secret:acm-observability-certs:tls.crt
        key_file: secret:acm-observability-certs:tls.key
        type: none
        use_kiali_token: false
      thanos_proxy:
        enabled: true
        retention_period: "365d"
        scrape_interval: "5m"
      url: "${OBSERVATORIUM_URL}"
  version: default
EOF

  wait_for "Kiali CR reconciled" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait kiali kiali -n istio-system --for=condition=Successful --timeout=10s"

  wait_for "Kiali deployment ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} rollout status deployment/kiali -n istio-system --timeout=10s"

  # Install OSSMConsole
  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: kiali.io/v1alpha1
kind: OSSMConsole
metadata:
  name: ossmconsole
  namespace: istio-system
spec: {}
EOF

  wait_for "OSSMConsole reconciled" "${TIMEOUT}" \
    "[ \"\$(oc --context=${SPOKE_CTX} get ossmconsole ossmconsole -n istio-system -o jsonpath='{.status.conditions[?(@.type==\"Successful\")].status}' 2>/dev/null)\" = 'True' ]"
}

guide1_phase5_demo_apps() {
  info "=== Guide 1 Phase 5: Demo Applications ==="

  local ISTIO_MINOR
  ISTIO_MINOR=$(echo "${ISTIO_VERSION}" | cut -d. -f1-2)

  # Ambient demo
  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: ambient-demo
  labels:
    istio.io/dataplane-mode: ambient
    istio-discovery: enabled
EOF

  curl -sL "https://raw.githubusercontent.com/openshift-service-mesh/istio/release-${ISTIO_MINOR}/samples/helloworld/helloworld.yaml" \
    -o "${TMP_DIR}/helloworld.yaml"

  oc --context="${SPOKE_CTX}" apply -n ambient-demo -l service=helloworld -f "${TMP_DIR}/helloworld.yaml"
  oc --context="${SPOKE_CTX}" apply -n ambient-demo -l version=v1 -f "${TMP_DIR}/helloworld.yaml"
  oc --context="${SPOKE_CTX}" apply -n ambient-demo -l version=v2 -f "${TMP_DIR}/helloworld.yaml"

  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: traffic-gen
  namespace: ambient-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: traffic-gen
  template:
    metadata:
      labels:
        app: traffic-gen
    spec:
      containers:
      - name: client
        image: registry.access.redhat.com/ubi9/ubi-minimal:latest
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            curl -s --max-time 5 http://helloworld:5000/hello || echo "failed"
            sleep 2
          done
EOF

  wait_for "helloworld-v1 available" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait deployment/helloworld-v1 -n ambient-demo --for=condition=Available --timeout=10s"
  wait_for "helloworld-v2 available" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait deployment/helloworld-v2 -n ambient-demo --for=condition=Available --timeout=10s"

  # Waypoint
  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: waypoint
  namespace: ambient-demo
  labels:
    istio.io/waypoint-for: service
spec:
  gatewayClassName: istio-waypoint
  listeners:
  - name: mesh
    port: 15008
    protocol: HBONE
EOF

  wait_for "Waypoint programmed on spoke" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait gateway/waypoint -n ambient-demo --for=condition=Programmed=True --timeout=10s"

  oc --context="${SPOKE_CTX}" label namespace ambient-demo istio.io/use-waypoint=waypoint --overwrite

  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: istio-proxies-monitor
  namespace: ambient-demo
spec:
  selector:
    matchExpressions:
    - key: istio-prometheus-ignore
      operator: DoesNotExist
  podMetricsEndpoints:
  - path: /stats/prometheus
    interval: 30s
    relabelings:
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_container_name"]
      regex: "istio-proxy"
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_annotationpresent_prometheus_io_scrape"]
    - action: replace
      regex: (\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})
      replacement: '[\$2]:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - action: replace
      regex: (\d+);((([0-9]+?)(\.|$)){4})
      replacement: '\$2:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - sourceLabels: ["__meta_kubernetes_namespace"]
      action: replace
      targetLabel: namespace
    - action: replace
      replacement: "${MESH_ID}"
      targetLabel: mesh_id
EOF

  # Bookinfo (sidecar demo)
  oc --context="${SPOKE_CTX}" create namespace bookinfo 2>/dev/null || true
  oc --context="${SPOKE_CTX}" label namespace bookinfo istio-injection=enabled istio-discovery=enabled --overwrite

  oc --context="${SPOKE_CTX}" apply -n bookinfo \
    -f "https://raw.githubusercontent.com/openshift-service-mesh/istio/release-${ISTIO_MINOR}/samples/bookinfo/platform/kube/bookinfo.yaml"

  wait_for "Bookinfo pods ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait pods --for=condition=Ready --all -n bookinfo --timeout=10s"

  oc --context="${SPOKE_CTX}" apply -n bookinfo \
    -f "https://raw.githubusercontent.com/openshift-service-mesh/istio/release-${ISTIO_MINOR}/samples/bookinfo/gateway-api/bookinfo-gateway.yaml"

  wait_for "Bookinfo gateway programmed" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait --for=condition=Programmed gateway/bookinfo-gateway -n bookinfo --timeout=10s"

  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: traffic-gen
  namespace: bookinfo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: traffic-gen
  template:
    metadata:
      labels:
        app: traffic-gen
    spec:
      containers:
      - name: client
        image: registry.access.redhat.com/ubi9/ubi-minimal:latest
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            curl -s -o /dev/null -w "%{http_code}\n" --max-time 5 http://productpage:9080/productpage || echo "failed"
            sleep 2
          done
EOF

  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: istio-proxies-monitor
  namespace: bookinfo
spec:
  selector:
    matchExpressions:
    - key: istio-prometheus-ignore
      operator: DoesNotExist
  podMetricsEndpoints:
  - path: /stats/prometheus
    interval: 30s
    relabelings:
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_container_name"]
      regex: "istio-proxy"
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_annotationpresent_prometheus_io_scrape"]
    - action: replace
      regex: (\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})
      replacement: '[\$2]:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - action: replace
      regex: (\d+);((([0-9]+?)(\.|$)){4})
      replacement: '\$2:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - sourceLabels: ["__meta_kubernetes_pod_label_app_kubernetes_io_name","__meta_kubernetes_pod_label_app"]
      separator: ";"
      targetLabel: "app"
      action: replace
      regex: "(.+);.*|.*;(.+)"
      replacement: "\${1}\${2}"
    - sourceLabels: ["__meta_kubernetes_pod_label_app_kubernetes_io_version","__meta_kubernetes_pod_label_version"]
      separator: ";"
      targetLabel: "version"
      action: replace
      regex: "(.+);.*|.*;(.+)"
      replacement: "\${1}\${2}"
    - sourceLabels: ["__meta_kubernetes_namespace"]
      action: replace
      targetLabel: namespace
    - action: replace
      replacement: "${MESH_ID}"
      targetLabel: mesh_id
EOF
}

guide1_phase6_verification() {
  info "=== Guide 1 Phase 6: Verification ==="

  wait_for "Istio metrics in hub Thanos" "${TIMEOUT}" \
    "oc --context=${HUB_CTX} get --raw '/api/v1/namespaces/open-cluster-management-observability/services/http:observability-thanos-query-frontend:9090/proxy/api/v1/label/__name__/values' | jq -r '.data[]' | grep -q '^istio_'"

  info "Guide 1 verification passed - Istio metrics visible in hub Thanos"
}

# =============================================================================
# Guide 2: Multi-Primary Mesh
# =============================================================================

guide2_phase1_spoke_two_ca() {
  info "=== Guide 2 Phase 1: Generate Spoke-Two CA ==="

  mkdir -p "${TMP_DIR}/istio-certs/spoke-two"
  cd "${TMP_DIR}/istio-certs"

  cat > spoke-two/intermediate.conf <<'CONF'
[ req ]
encrypt_key = no
prompt = no
utf8 = yes
default_md = sha256
default_bits = 4096
req_extensions = req_ext
x509_extensions = req_ext
distinguished_name = req_dn
[ req_ext ]
subjectKeyIdentifier = hash
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment, keyCertSign
subjectAltName=@san
[ san ]
DNS.1 = istiod.istio-system.svc
[ req_dn ]
O = Istio
CN = Intermediate CA
L = spoke-two
CONF

  openssl genrsa -out spoke-two/ca-key.pem 4096 2>/dev/null
  openssl req -new -config spoke-two/intermediate.conf -key spoke-two/ca-key.pem -out spoke-two/cluster-ca.csr 2>/dev/null
  openssl x509 -req -sha256 -days 3650 -CA root-cert.pem -CAkey root-key.pem -CAcreateserial \
    -extensions req_ext -extfile spoke-two/intermediate.conf -in spoke-two/cluster-ca.csr -out spoke-two/ca-cert.pem 2>/dev/null
  cat spoke-two/ca-cert.pem root-cert.pem > spoke-two/cert-chain.pem
  cp root-cert.pem spoke-two/root-cert.pem

  cd -
}

guide2_phase2_import_spoke_two() {
  info "=== Guide 2 Phase 2: Import Spoke-Two into ACM ==="

  oc --context="${HUB_CTX}" create namespace "${SPOKE_TWO_CLUSTER_NAME}" 2>/dev/null || true

  oc --context="${HUB_CTX}" apply -f - <<EOF
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: ${SPOKE_TWO_CLUSTER_NAME}
  labels:
    cloud: auto-detect
    vendor: auto-detect
spec:
  hubAcceptsClient: true
EOF

  oc --context="${HUB_CTX}" apply -f - <<EOF
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: ${SPOKE_TWO_CLUSTER_NAME}
  namespace: ${SPOKE_TWO_CLUSTER_NAME}
spec:
  applicationManager:
    enabled: true
  certPolicyController:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
EOF

  oc config view --context="${SPOKE_TWO_CTX}" --minify --flatten \
    > "${TMP_DIR}/spoke-two-kubeconfig.yaml"

  oc --context="${HUB_CTX}" create secret generic auto-import-secret \
    -n "${SPOKE_TWO_CLUSTER_NAME}" \
    --from-file=kubeconfig="${TMP_DIR}/spoke-two-kubeconfig.yaml" 2>/dev/null || true

  rm -f "${TMP_DIR}/spoke-two-kubeconfig.yaml"

  wait_for "Spoke-two joined and available" "${TIMEOUT}" \
    "oc --context=${HUB_CTX} get managedcluster ${SPOKE_TWO_CLUSTER_NAME} -o jsonpath='{range .status.conditions[*]}{.type}={.status} {end}' | grep -q 'ManagedClusterJoined=True' && oc --context=${HUB_CTX} get managedcluster ${SPOKE_TWO_CLUSTER_NAME} -o jsonpath='{range .status.conditions[*]}{.type}={.status} {end}' | grep -q 'ManagedClusterConditionAvailable=True'"
}

guide2_phase3_ossm3_spoke_two() {
  info "=== Guide 2 Phase 3: Install OSSM 3 on Spoke-Two ==="

  # Enable UWM (safe merge — does not overwrite unrelated monitoring settings)
  enable_uwm "${SPOKE_TWO_CTX}"

  wait_for "UWM Prometheus ready on spoke-two" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} wait pod --for=condition=Ready -l app.kubernetes.io/name=prometheus -n openshift-user-workload-monitoring --timeout=10s"

  # Ensure target namespaces exist so MCOA can propagate PrometheusRules into them
  local ns
  for ns in istio-system ztunnel ambient-demo bookinfo; do
    oc --context="${SPOKE_TWO_CTX}" create namespace "${ns}" --dry-run=client -o yaml | \
      oc --context="${SPOKE_TWO_CTX}" apply -f - 2>/dev/null || true
  done

  # Install OSSM 3 Operator
  oc --context="${SPOKE_TWO_CTX}" apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-service-mesh-operator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: servicemeshoperator3
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

  wait_for "OSSM operator ready on spoke-two" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} wait pod --for=condition=Ready -l app.kubernetes.io/created-by=servicemeshoperator3 -n openshift-operators --timeout=10s"

  # Create namespaces
  oc --context="${SPOKE_TWO_CTX}" create namespace istio-system 2>/dev/null || true
  oc --context="${SPOKE_TWO_CTX}" create namespace istio-cni 2>/dev/null || true
  oc --context="${SPOKE_TWO_CTX}" create namespace ztunnel 2>/dev/null || true

  oc --context="${SPOKE_TWO_CTX}" label namespace ztunnel istio-discovery=enabled --overwrite
  oc --context="${SPOKE_TWO_CTX}" label namespace istio-system \
    "topology.istio.io/network=${SPOKE_TWO_NETWORK}" \
    istio-discovery=enabled --overwrite

  # Load CA certs
  oc --context="${SPOKE_TWO_CTX}" get secret cacerts -n istio-system &>/dev/null || \
  oc --context="${SPOKE_TWO_CTX}" create secret generic cacerts -n istio-system \
    --from-file=ca-cert.pem="${TMP_DIR}/istio-certs/spoke-two/ca-cert.pem" \
    --from-file=ca-key.pem="${TMP_DIR}/istio-certs/spoke-two/ca-key.pem" \
    --from-file=root-cert.pem="${TMP_DIR}/istio-certs/spoke-two/root-cert.pem" \
    --from-file=cert-chain.pem="${TMP_DIR}/istio-certs/spoke-two/cert-chain.pem"

  # IstioCNI
  oc --context="${SPOKE_TWO_CTX}" apply -f - <<EOF
apiVersion: sailoperator.io/v1
kind: IstioCNI
metadata:
  name: default
spec:
  namespace: istio-cni
  profile: openshift-ambient
  version: v${ISTIO_VERSION}
EOF

  wait_for "IstioCNI ready on spoke-two" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} wait istiocni default --for=condition=Ready --timeout=10s"

  # Istio control plane
  oc --context="${SPOKE_TWO_CTX}" apply -f - <<EOF
apiVersion: sailoperator.io/v1
kind: Istio
metadata:
  name: default
spec:
  namespace: istio-system
  profile: openshift-ambient
  updateStrategy:
    type: InPlace
  values:
    global:
      meshID: ${MESH_ID}
      multiCluster:
        clusterName: ${SPOKE_TWO_CLUSTER_NAME}
      network: ${SPOKE_TWO_NETWORK}
    meshConfig:
      discoverySelectors:
      - matchLabels:
          istio-discovery: enabled
    pilot:
      trustedZtunnelNamespace: ztunnel
      env:
        AMBIENT_ENABLE_MULTI_NETWORK: "true"
  version: v${ISTIO_VERSION}
EOF

  wait_for "Istio ready on spoke-two" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} wait istio default --for=condition=Ready --timeout=10s"

  # ZTunnel
  oc --context="${SPOKE_TWO_CTX}" apply -f - <<EOF
apiVersion: sailoperator.io/v1
kind: ZTunnel
metadata:
  name: default
spec:
  namespace: ztunnel
  version: v${ISTIO_VERSION}
  values:
    ztunnel:
      multiCluster:
        clusterName: ${SPOKE_TWO_CLUSTER_NAME}
      network: ${SPOKE_TWO_NETWORK}
EOF

  wait_for "ZTunnel ready on spoke-two" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} wait ztunnel default --for=condition=Ready --timeout=10s"

  # Metrics collection
  oc --context="${SPOKE_TWO_CTX}" apply -f - <<'EOF'
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: istiod-monitor
  namespace: istio-system
spec:
  targetLabels:
  - app
  selector:
    matchLabels:
      istio: pilot
  endpoints:
  - port: http-monitoring
    interval: 30s
EOF

  oc --context="${SPOKE_TWO_CTX}" apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: ztunnel-monitor
  namespace: ztunnel
spec:
  selector:
    matchExpressions:
    - key: istio-prometheus-ignore
      operator: DoesNotExist
  podMetricsEndpoints:
  - path: /stats/prometheus
    interval: 30s
    relabelings:
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_container_name"]
      regex: "istio-proxy"
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_annotationpresent_prometheus_io_scrape"]
    - action: replace
      regex: (\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})
      replacement: '[\$2]:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - action: replace
      regex: (\d+);((([0-9]+?)(\.|$)){4})
      replacement: '\$2:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - sourceLabels: ["__meta_kubernetes_namespace"]
      action: replace
      targetLabel: namespace
    - action: replace
      replacement: "${MESH_ID}"
      targetLabel: mesh_id
EOF
}

guide2_phase4_update_spoke() {
  info "=== Guide 2 Phase 4: Update Spoke for Multi-Primary ==="

  oc --context="${SPOKE_CTX}" label namespace istio-system \
    "topology.istio.io/network=${SPOKE_NETWORK}" \
    istio-discovery=enabled --overwrite

  oc --context="${SPOKE_CTX}" patch istio default --type=merge -p "{
    \"spec\": {
      \"values\": {
        \"global\": {
          \"multiCluster\": {\"clusterName\": \"${SPOKE_CLUSTER_NAME}\"},
          \"network\": \"${SPOKE_NETWORK}\"
        },
        \"pilot\": {
          \"env\": {
            \"AMBIENT_ENABLE_MULTI_NETWORK\": \"true\"
          }
        }
      }
    }
  }"

  wait_for "Istio ready after multi-cluster patch" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait istio default --for=condition=Ready --timeout=10s"

  oc --context="${SPOKE_CTX}" patch ztunnel default --type=merge -p "{
    \"spec\": {
      \"values\": {
        \"ztunnel\": {
          \"multiCluster\": {\"clusterName\": \"${SPOKE_CLUSTER_NAME}\"},
          \"network\": \"${SPOKE_NETWORK}\"
        }
      }
    }
  }"

  wait_for "ZTunnel ready after multi-cluster patch" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait ztunnel default --for=condition=Ready --timeout=10s"

  # Update Kiali with cluster name
  oc --context="${SPOKE_CTX}" patch kiali kiali -n istio-system --type=merge -p "{
    \"spec\": {
      \"kubernetes_config\": {
        \"cluster_name\": \"${SPOKE_CLUSTER_NAME}\"
      }
    }
  }"

  wait_for "Kiali rollout after cluster_name update" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} rollout status deployment/kiali -n istio-system --timeout=10s"

  # Wait for sidecar injector to reflect clusterName
  wait_for "Sidecar injector reflects clusterName" "${TIMEOUT}" \
    "[ \"\$(oc --context=${SPOKE_CTX} get configmap istio-sidecar-injector -n istio-system -o jsonpath='{.data.values}' | jq -r '.global.multiCluster.clusterName // empty')\" = '${SPOKE_CLUSTER_NAME}' ]"

  # Restart bookinfo to pick up new cluster identity
  oc --context="${SPOKE_CTX}" rollout restart deployment -n bookinfo

  wait_for "Bookinfo deployments available after restart" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait deployment --all -n bookinfo --for=condition=Available --timeout=10s"
}

guide2_phase5_east_west_gateways() {
  info "=== Guide 2 Phase 5: East-West Gateways ==="

  # HBONE gateways
  for CTX_AND_NET in "${SPOKE_CTX}:${SPOKE_NETWORK}" "${SPOKE_TWO_CTX}:${SPOKE_TWO_NETWORK}"; do
    local CTX="${CTX_AND_NET%%:*}"
    local NET="${CTX_AND_NET##*:}"
    oc --context="${CTX}" apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: istio-eastwestgateway
  namespace: istio-system
  labels:
    topology.istio.io/network: ${NET}
spec:
  gatewayClassName: istio-east-west
  listeners:
  - name: mesh
    port: 15008
    protocol: HBONE
    tls:
      mode: Terminate
      options:
        gateway.istio.io/tls-terminate-mode: ISTIO_MUTUAL
EOF
    wait_for "HBONE gateway programmed on ${CTX}" "${TIMEOUT}" \
      "oc --context=${CTX} wait gateway/istio-eastwestgateway -n istio-system --for=condition=Programmed=True --timeout=10s"
  done

  # Sidecar gateways
  for CTX_AND_NET in "${SPOKE_CTX}:${SPOKE_NETWORK}" "${SPOKE_TWO_CTX}:${SPOKE_TWO_NETWORK}"; do
    local CTX="${CTX_AND_NET%%:*}"
    local NET="${CTX_AND_NET##*:}"
    oc --context="${CTX}" apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: istio-eastwestgateway-sidecar
  namespace: istio-system
  labels:
    topology.istio.io/network: ${NET}
spec:
  gatewayClassName: istio
  listeners:
  - name: tls
    port: 15443
    protocol: TLS
    tls:
      mode: Passthrough
    allowedRoutes:
      namespaces:
        from: Same
EOF
    wait_for "Sidecar gateway programmed on ${CTX}" "${TIMEOUT}" \
      "oc --context=${CTX} wait gateway/istio-eastwestgateway-sidecar -n istio-system --for=condition=Programmed=True --timeout=10s"
  done

  # Configure meshNetworks
  local HBONE_IP1 SIDECAR_IP1 HBONE_IP2 SIDECAR_IP2
  HBONE_IP1=$(oc --context="${SPOKE_CTX}" get svc istio-eastwestgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  SIDECAR_IP1=$(oc --context="${SPOKE_CTX}" get svc istio-eastwestgateway-sidecar-istio -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  HBONE_IP2=$(oc --context="${SPOKE_TWO_CTX}" get svc istio-eastwestgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  SIDECAR_IP2=$(oc --context="${SPOKE_TWO_CTX}" get svc istio-eastwestgateway-sidecar-istio -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  info "Spoke: HBONE=${HBONE_IP1} Sidecar=${SIDECAR_IP1}"
  info "Spoke-two: HBONE=${HBONE_IP2} Sidecar=${SIDECAR_IP2}"

  for CTX in "${SPOKE_CTX}" "${SPOKE_TWO_CTX}"; do
    oc --context="${CTX}" patch istio default --type=merge -p "{
      \"spec\": {
        \"values\": {
          \"global\": {
            \"meshNetworks\": {
              \"${SPOKE_NETWORK}\": {
                \"endpoints\": [{\"fromRegistry\": \"${SPOKE_CLUSTER_NAME}\"}],
                \"gateways\": [
                  {\"address\": \"${HBONE_IP1}\", \"port\": 15008},
                  {\"address\": \"${SIDECAR_IP1}\", \"port\": 15443}
                ]
              },
              \"${SPOKE_TWO_NETWORK}\": {
                \"endpoints\": [{\"fromRegistry\": \"${SPOKE_TWO_CLUSTER_NAME}\"}],
                \"gateways\": [
                  {\"address\": \"${HBONE_IP2}\", \"port\": 15008},
                  {\"address\": \"${SIDECAR_IP2}\", \"port\": 15443}
                ]
              }
            }
          }
        }
      }
    }"
  done
}

guide2_phase6_endpoint_discovery() {
  info "=== Guide 2 Phase 6: Cross-Cluster Endpoint Discovery ==="

  oc --context="${SPOKE_CTX}" create serviceaccount istio-reader-service-account -n istio-system 2>/dev/null || true
  oc --context="${SPOKE_CTX}" adm policy add-cluster-role-to-user cluster-reader -z istio-reader-service-account -n istio-system

  oc --context="${SPOKE_TWO_CTX}" create serviceaccount istio-reader-service-account -n istio-system 2>/dev/null || true
  oc --context="${SPOKE_TWO_CTX}" adm policy add-cluster-role-to-user cluster-reader -z istio-reader-service-account -n istio-system

  # Remote secret: spoke-two -> spoke (lets spoke discover spoke-two endpoints)
  istioctl create-remote-secret \
    --context="${SPOKE_TWO_CTX}" \
    --name="${SPOKE_TWO_CLUSTER_NAME}" \
    --create-service-account=false | \
    oc --context="${SPOKE_CTX}" apply -f -

  # Remote secret: spoke -> spoke-two (lets spoke-two discover spoke endpoints)
  istioctl create-remote-secret \
    --context="${SPOKE_CTX}" \
    --name="${SPOKE_CLUSTER_NAME}" \
    --create-service-account=false | \
    oc --context="${SPOKE_TWO_CTX}" apply -f -
}

guide2_phase7_kiali_multicluster() {
  info "=== Guide 2 Phase 7: Kiali Multi-Cluster Access ==="

  # Install Kiali Operator on spoke-two
  oc --context="${SPOKE_TWO_CTX}" apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-ossm
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: kiali-ossm
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

  wait_for "Kiali operator ready on spoke-two" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} wait pod --for=condition=Ready -l app.kubernetes.io/name=kiali-operator -n openshift-operators --timeout=10s"

  # Required for the tutorial's non-impersonation per-cluster OAuth flow.
  # If impersonation is enabled in a Kiali version that supports it, this is not technically needed.
  local KIALI_HOST
  KIALI_HOST=$(oc --context="${SPOKE_CTX}" get route kiali -n istio-system -o jsonpath='{.spec.host}')

  # Install Kiali CR on spoke-two (remote resources only)
  oc --context="${SPOKE_TWO_CTX}" apply -f - <<EOF
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: istio-system
spec:
  auth:
    openshift:
      impersonation:
        enabled: false
      redirect_uris:
      - "https://${KIALI_HOST}/api/auth/callback/${SPOKE_TWO_CLUSTER_NAME}"
  deployment:
    namespace: istio-system
    remote_cluster_resources_only: true
EOF

  wait_for "Kiali CR reconciled on spoke-two" "${TIMEOUT}" \
    "[ \"\$(oc --context=${SPOKE_TWO_CTX} get kiali kiali -n istio-system -o jsonpath='{.status.conditions[?(@.type==\"Successful\")].status}' 2>/dev/null)\" = 'True' ]"

  # Create SA token secret on spoke-two
  oc --context="${SPOKE_TWO_CTX}" apply -f - <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: "kiali-service-account"
  namespace: "istio-system"
  annotations:
    kubernetes.io/service-account.name: "kiali-service-account"
type: kubernetes.io/service-account-token
EOF

  wait_for "Kiali SA token populated" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} get secret kiali-service-account -n istio-system -o jsonpath='{.data.token}' | grep -q ."

  # Build kubeconfig for spoke-two
  local SPOKE_TWO_SERVER SPOKE_TWO_CA SPOKE_TWO_TOKEN
  SPOKE_TWO_SERVER=$(oc --context="${SPOKE_TWO_CTX}" whoami --show-server | tr -d '[:space:]')
  SPOKE_TWO_CA=$(oc --context="${SPOKE_TWO_CTX}" get secret kiali-service-account -n istio-system -o jsonpath='{.data.ca\.crt}')
  SPOKE_TWO_TOKEN=$(oc --context="${SPOKE_TWO_CTX}" get secret kiali-service-account -n istio-system -o jsonpath='{.data.token}' | base64 -d)

  cat > "${TMP_DIR}/cluster2-kubeconfig.yaml" <<EOF
apiVersion: v1
kind: Config
current-context: ${SPOKE_TWO_CLUSTER_NAME}
contexts:
- name: ${SPOKE_TWO_CLUSTER_NAME}
  context:
    cluster: ${SPOKE_TWO_CLUSTER_NAME}
    user: ${SPOKE_TWO_CLUSTER_NAME}
clusters:
- name: ${SPOKE_TWO_CLUSTER_NAME}
  cluster:
    server: ${SPOKE_TWO_SERVER}
    certificate-authority-data: ${SPOKE_TWO_CA}
users:
- name: ${SPOKE_TWO_CLUSTER_NAME}
  user:
    token: ${SPOKE_TWO_TOKEN}
EOF

  # Create multi-cluster secret on spoke
  oc --context="${SPOKE_CTX}" create secret generic kiali-multi-cluster-secret \
    -n istio-system \
    --from-file="${SPOKE_TWO_CLUSTER_NAME}=${TMP_DIR}/cluster2-kubeconfig.yaml" 2>/dev/null || true

  oc --context="${SPOKE_CTX}" label secret kiali-multi-cluster-secret \
    -n istio-system \
    "kiali.io/kiali-multi-cluster-secret=true" --overwrite

  rm -f "${TMP_DIR}/cluster2-kubeconfig.yaml"

  wait_for "Kiali rollout after multi-cluster secret" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} rollout status deployment/kiali -n istio-system --timeout=10s"
}

guide2_phase8_demo_apps_spoke_two() {
  info "=== Guide 2 Phase 8: Demo Apps on Spoke-Two ==="

  local ISTIO_MINOR
  ISTIO_MINOR=$(echo "${ISTIO_VERSION}" | cut -d. -f1-2)

  # Ambient demo on spoke-two
  oc --context="${SPOKE_TWO_CTX}" create namespace ambient-demo 2>/dev/null || true
  oc --context="${SPOKE_TWO_CTX}" label namespace ambient-demo \
    istio.io/dataplane-mode=ambient istio-discovery=enabled --overwrite

  curl -sL "https://raw.githubusercontent.com/openshift-service-mesh/istio/release-${ISTIO_MINOR}/samples/helloworld/helloworld.yaml" \
    -o "${TMP_DIR}/helloworld.yaml"

  oc --context="${SPOKE_TWO_CTX}" apply -n ambient-demo -l service=helloworld -f "${TMP_DIR}/helloworld.yaml"
  oc --context="${SPOKE_TWO_CTX}" apply -n ambient-demo -l version=v1 -f "${TMP_DIR}/helloworld.yaml"
  oc --context="${SPOKE_TWO_CTX}" apply -n ambient-demo -l version=v2 -f "${TMP_DIR}/helloworld.yaml"

  wait_for "helloworld-v1 available on spoke-two" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} wait deployment/helloworld-v1 -n ambient-demo --for=condition=Available --timeout=10s"
  wait_for "helloworld-v2 available on spoke-two" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} wait deployment/helloworld-v2 -n ambient-demo --for=condition=Available --timeout=10s"

  # Label services global on both clusters
  oc --context="${SPOKE_CTX}" label svc helloworld -n ambient-demo istio.io/global=true --overwrite
  oc --context="${SPOKE_TWO_CTX}" label svc helloworld -n ambient-demo istio.io/global=true --overwrite

  # Waypoint on spoke-two
  oc --context="${SPOKE_TWO_CTX}" apply -f - <<'EOF'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: waypoint
  namespace: ambient-demo
  labels:
    istio.io/waypoint-for: service
spec:
  gatewayClassName: istio-waypoint
  listeners:
  - name: mesh
    port: 15008
    protocol: HBONE
EOF

  wait_for "Waypoint programmed on spoke-two" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} wait gateway/waypoint -n ambient-demo --for=condition=Programmed=True --timeout=10s"

  oc --context="${SPOKE_TWO_CTX}" label namespace ambient-demo istio.io/use-waypoint=waypoint --overwrite

  # PodMonitors on spoke-two
  oc --context="${SPOKE_TWO_CTX}" apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: istio-proxies-monitor
  namespace: ambient-demo
spec:
  selector:
    matchExpressions:
    - key: istio-prometheus-ignore
      operator: DoesNotExist
  podMetricsEndpoints:
  - path: /stats/prometheus
    interval: 30s
    relabelings:
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_container_name"]
      regex: "istio-proxy"
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_annotationpresent_prometheus_io_scrape"]
    - action: replace
      regex: (\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})
      replacement: '[\$2]:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - action: replace
      regex: (\d+);((([0-9]+?)(\.|$)){4})
      replacement: '\$2:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - sourceLabels: ["__meta_kubernetes_namespace"]
      action: replace
      targetLabel: namespace
    - action: replace
      replacement: "${MESH_ID}"
      targetLabel: mesh_id
EOF

  # Bookinfo ratings-v2 on spoke-two (sidecar demo)
  oc --context="${SPOKE_TWO_CTX}" create namespace bookinfo 2>/dev/null || true
  oc --context="${SPOKE_TWO_CTX}" label namespace bookinfo istio-injection=enabled istio-discovery=enabled --overwrite

  oc --context="${SPOKE_TWO_CTX}" apply -f - <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: bookinfo-ratings
  namespace: bookinfo
---
apiVersion: v1
kind: Service
metadata:
  name: ratings
  namespace: bookinfo
  labels:
    app: ratings
    service: ratings
spec:
  ports:
  - port: 9080
    name: http
  selector:
    app: ratings
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ratings-v2
  namespace: bookinfo
  labels:
    app: ratings
    version: v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ratings
      version: v2
  template:
    metadata:
      labels:
        app: ratings
        version: v2
    spec:
      serviceAccountName: bookinfo-ratings
      containers:
      - name: ratings
        image: docker.io/istio/examples-bookinfo-ratings-v1:1.20.3
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
EOF

  wait_for "ratings-v2 available on spoke-two" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} wait deployment/ratings-v2 -n bookinfo --for=condition=Available --timeout=10s"

  # Label ratings global
  oc --context="${SPOKE_CTX}" label svc ratings -n bookinfo istio.io/global=true --overwrite
  oc --context="${SPOKE_TWO_CTX}" label svc ratings -n bookinfo istio.io/global=true --overwrite

  # PodMonitor for bookinfo on spoke-two
  oc --context="${SPOKE_TWO_CTX}" apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: istio-proxies-monitor
  namespace: bookinfo
spec:
  selector:
    matchExpressions:
    - key: istio-prometheus-ignore
      operator: DoesNotExist
  podMetricsEndpoints:
  - path: /stats/prometheus
    interval: 30s
    relabelings:
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_container_name"]
      regex: "istio-proxy"
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_annotationpresent_prometheus_io_scrape"]
    - action: replace
      regex: (\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})
      replacement: '[\$2]:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - action: replace
      regex: (\d+);((([0-9]+?)(\.|$)){4})
      replacement: '\$2:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - sourceLabels: ["__meta_kubernetes_pod_label_app_kubernetes_io_name","__meta_kubernetes_pod_label_app"]
      separator: ";"
      targetLabel: "app"
      action: replace
      regex: "(.+);.*|.*;(.+)"
      replacement: "\${1}\${2}"
    - sourceLabels: ["__meta_kubernetes_pod_label_app_kubernetes_io_version","__meta_kubernetes_pod_label_version"]
      separator: ";"
      targetLabel: "version"
      action: replace
      regex: "(.+);.*|.*;(.+)"
      replacement: "\${1}\${2}"
    - sourceLabels: ["__meta_kubernetes_namespace"]
      action: replace
      targetLabel: namespace
    - action: replace
      replacement: "${MESH_ID}"
      targetLabel: mesh_id
EOF
}

guide2_phase9_verification() {
  info "=== Guide 2 Phase 9: Verification ==="

  wait_for "Cross-cluster traffic (helloworld instances from spoke-two)" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} logs -n ambient-demo deployment/traffic-gen --tail=30 2>/dev/null | grep -q 'Hello version'"

  info "Guide 2 verification passed - cross-cluster traffic flowing"
}

# =============================================================================
# Guide 3: Dashboards and Tracing
# =============================================================================

guide3_phase1_perses() {
  info "=== Guide 3 Phase 1: Perses ==="

  # Perses requires the full COO product; MCOA alone is not sufficient.
  install_coo "${SPOKE_CTX}"

  wait_for "Perses CRD ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} get crd perses.perses.dev"

  # Find COO namespace dynamically (may be openshift-cluster-observability-operator or openshift-operators)
  local COO_NS
  COO_NS=$(oc --context="${SPOKE_CTX}" get subscriptions.operators.coreos.com -A -o json 2>/dev/null | \
    jq -r '[.items[] | select(.spec.name == "cluster-observability-operator")][0] |
      select(. != null) | .metadata.namespace' 2>/dev/null || echo "openshift-cluster-observability-operator")

  wait_for "COO Perses operator ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait pod --for=condition=Ready -l app.kubernetes.io/name=perses-operator -n ${COO_NS} --timeout=10s"

  # Create UIPlugin for Perses
  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: observability.openshift.io/v1alpha1
kind: UIPlugin
metadata:
  name: monitoring
spec:
  type: Monitoring
  monitoring:
    perses:
      enabled: true
EOF

  wait_for "Perses pod ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait pod --for=condition=Ready -l app.kubernetes.io/name=perses -n ${COO_NS} --timeout=10s"

  # Prepare certs for Perses datasource
  local OBSERVATORIUM_URL
  OBSERVATORIUM_URL=$(oc --context="${HUB_CTX}" get route observatorium-api \
    -n open-cluster-management-observability \
    -o jsonpath='https://{.spec.host}/api/metrics/v1/default')

  oc --context="${HUB_CTX}" get secret observability-server-ca-certs \
    -n open-cluster-management-observability \
    -o jsonpath='{.data.ca\.crt}' | base64 -d > "${TMP_DIR}/perses-server-ca.crt"

  oc --context="${SPOKE_CTX}" create configmap perses-acm-server-ca \
    -n "${COO_NS}" \
    --from-file=ca.crt="${TMP_DIR}/perses-server-ca.crt" \
    --dry-run=client -o yaml | oc --context="${SPOKE_CTX}" apply -f -

  oc --context="${SPOKE_CTX}" get secret acm-observability-certs -n istio-system -o json | \
    jq --arg ns "${COO_NS}" \
      'del(.metadata.namespace, .metadata.resourceVersion, .metadata.uid, .metadata.creationTimestamp, .metadata.ownerReferences) | .metadata.namespace = $ns | .metadata.name = "perses-acm-client-certs"' | \
    oc --context="${SPOKE_CTX}" apply -f -

  # Mount CA into Perses pod
  oc --context="${SPOKE_CTX}" patch perses perses -n "${COO_NS}" --type=merge -p '{
    "spec": {
      "volumes": [{"name": "acm-server-ca", "configMap": {"name": "perses-acm-server-ca"}}],
      "volumeMounts": [{"name": "acm-server-ca", "mountPath": "/etc/ssl/certs/acm-thanos-ca.crt", "subPath": "ca.crt", "readOnly": true}]
    }
  }'

  wait_for "Perses pod ready after volume mount" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait pod --for=condition=Ready -l app.kubernetes.io/name=perses -n ${COO_NS} --timeout=10s"

  # Create namespace and datasource
  oc --context="${SPOKE_CTX}" create namespace perses 2>/dev/null || true

  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: perses.dev/v1alpha2
kind: PersesDatasource
metadata:
  name: acm-thanos
  namespace: perses
spec:
  config:
    display:
      name: "ACM Hub Thanos"
    default: false
    plugin:
      kind: PrometheusDatasource
      spec:
        proxy:
          kind: HTTPProxy
          spec:
            url: "${OBSERVATORIUM_URL}"
            secret: acm-thanos-secret
  client:
    tls:
      enable: true
      caCert:
        type: file
        certPath: /etc/ssl/certs/acm-thanos-ca.crt
      userCert:
        type: secret
        name: perses-acm-client-certs
        namespace: ${COO_NS}
        certPath: tls.crt
        privateKeyPath: tls.key
EOF

  # Create dashboards
  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: perses.dev/v1alpha2
kind: PersesDashboard
metadata:
  name: istio-mesh-overview
  namespace: perses
spec:
  config:
    display:
      name: "Istio Mesh Overview"
    duration: 30m
    layouts:
    - kind: Grid
      spec:
        display:
          title: "HTTP Traffic"
        items:
        - content:
            $ref: '#/spec/panels/request_rate'
          height: 8
          width: 12
          x: 0
          "y": 0
        - content:
            $ref: '#/spec/panels/error_rate'
          height: 8
          width: 12
          x: 12
          "y": 0
    - kind: Grid
      spec:
        display:
          title: "TCP Traffic (Ambient / Ztunnel)"
        items:
        - content:
            $ref: '#/spec/panels/tcp_sent'
          height: 8
          width: 12
          x: 0
          "y": 0
        - content:
            $ref: '#/spec/panels/tcp_received'
          height: 8
          width: 12
          x: 12
          "y": 0
    panels:
      request_rate:
        kind: Panel
        spec:
          display:
            name: "Request Rate (rps)"
          plugin:
            kind: TimeSeriesChart
            spec:
              legend:
                mode: list
                position: bottom
          queries:
          - kind: TimeSeriesQuery
            spec:
              plugin:
                kind: PrometheusTimeSeriesQuery
                spec:
                  datasource:
                    kind: PrometheusDatasource
                    name: acm-thanos
                  query: sum(rate(istio_requests_total{reporter="destination"}[10m])) by (destination_service_name)
      error_rate:
        kind: Panel
        spec:
          display:
            name: "5xx Error Rate"
          plugin:
            kind: TimeSeriesChart
            spec:
              legend:
                mode: list
                position: bottom
          queries:
          - kind: TimeSeriesQuery
            spec:
              plugin:
                kind: PrometheusTimeSeriesQuery
                spec:
                  datasource:
                    kind: PrometheusDatasource
                    name: acm-thanos
                  query: sum(rate(istio_requests_total{reporter="destination",response_code=~"5.*"}[10m])) by (destination_service_name)
      tcp_sent:
        kind: Panel
        spec:
          display:
            name: "TCP Bytes Sent"
          plugin:
            kind: TimeSeriesChart
            spec:
              legend:
                mode: list
                position: bottom
          queries:
          - kind: TimeSeriesQuery
            spec:
              plugin:
                kind: PrometheusTimeSeriesQuery
                spec:
                  datasource:
                    kind: PrometheusDatasource
                    name: acm-thanos
                  query: sum(rate(istio_tcp_sent_bytes_total[10m])) by (destination_workload)
      tcp_received:
        kind: Panel
        spec:
          display:
            name: "TCP Bytes Received"
          plugin:
            kind: TimeSeriesChart
            spec:
              legend:
                mode: list
                position: bottom
          queries:
          - kind: TimeSeriesQuery
            spec:
              plugin:
                kind: PrometheusTimeSeriesQuery
                spec:
                  datasource:
                    kind: PrometheusDatasource
                    name: acm-thanos
                  query: sum(rate(istio_tcp_received_bytes_total[10m])) by (destination_workload)
EOF

  # Configure Kiali for Perses
  local CONSOLE_URL
  CONSOLE_URL=$(oc --context="${SPOKE_CTX}" get route console -n openshift-console -o jsonpath='https://{.spec.host}')

  oc --context="${SPOKE_CTX}" patch kiali kiali -n istio-system --type=merge -p "{
    \"spec\": {
      \"external_services\": {
        \"perses\": {
          \"enabled\": true,
          \"url_format\": \"openshift\",
          \"external_url\": \"${CONSOLE_URL}\",
          \"health_check_url\": \"https://perses.${COO_NS}.svc.cluster.local:8080/api/v1/health\",
          \"project\": \"perses\",
          \"dashboards\": [
            {\"name\": \"Istio Mesh Overview\"},
            {\"name\": \"Istio Workload Dashboard\", \"variables\": {\"namespace\": \"namespace\", \"workload\": \"workload\"}},
            {\"name\": \"Istio Ztunnel Dashboard\"}
          ]
        }
      }
    }
  }"

  wait_for "Kiali rollout after Perses config" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} rollout status deployment/kiali -n istio-system --timeout=10s"
}

guide3_phase2_tempo() {
  info "=== Guide 3 Phase 2: Tempo ==="

  # Install Tempo and OTEL operators
  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: tempo-product
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: tempo-product
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

  for CTX in "${SPOKE_CTX}" "${SPOKE_TWO_CTX}"; do
    oc --context="${CTX}" apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: opentelemetry-product
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: opentelemetry-product
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
  done

  wait_for "TempoStack CRD on spoke" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} get crd tempostacks.tempo.grafana.com"
  wait_for "OTel CRD on spoke" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} get crd opentelemetrycollectors.opentelemetry.io"
  wait_for "OTel CRD on spoke-two" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} get crd opentelemetrycollectors.opentelemetry.io"

  # Deploy MinIO and TempoStack
  oc --context="${SPOKE_CTX}" create namespace "${TEMPO_NAMESPACE}" 2>/dev/null || true

  oc --context="${SPOKE_CTX}" apply -n "${TEMPO_NAMESPACE}" -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio-pv-claim
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 256Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio
spec:
  selector:
    matchLabels:
      app: minio
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: minio
    spec:
      volumes:
      - name: storage
        persistentVolumeClaim:
          claimName: minio-pv-claim
      initContainers:
      - name: create-buckets
        image: mirror.gcr.io/library/busybox:1.28
        command: ["sh", "-c", "mkdir -p /storage/tempo-data"]
        volumeMounts:
        - name: storage
          mountPath: "/storage"
      containers:
      - name: minio
        image: quay.io/minio/minio:latest
        args:
        - server
        - /storage
        - --console-address
        - ":9001"
        env:
        - name: MINIO_ROOT_USER
          value: "minio"
        - name: MINIO_ROOT_PASSWORD
          value: "minio123"
        ports:
        - containerPort: 9000
        - containerPort: 9001
        volumeMounts:
        - name: storage
          mountPath: "/storage"
---
apiVersion: v1
kind: Service
metadata:
  name: minio
spec:
  type: ClusterIP
  ports:
  - port: 9000
    targetPort: 9000
    protocol: TCP
    name: api
  - port: 9001
    targetPort: 9001
    protocol: TCP
    name: console
  selector:
    app: minio
EOF

  wait_for "Tempo MinIO ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} rollout status deployment/minio -n ${TEMPO_NAMESPACE} --timeout=10s"

  oc --context="${SPOKE_CTX}" create secret generic tempostack-dev-minio \
    -n "${TEMPO_NAMESPACE}" \
    --from-literal=bucket="tempo-data" \
    --from-literal=endpoint="http://minio.${TEMPO_NAMESPACE}.svc.cluster.local:9000" \
    --from-literal=access_key_id="minio" \
    --from-literal=access_key_secret="minio123" \
    --dry-run=client -o yaml | oc --context="${SPOKE_CTX}" apply -f -

  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: tempo.grafana.com/v1alpha1
kind: TempoStack
metadata:
  name: ${TEMPO_STACK_NAME}
  namespace: ${TEMPO_NAMESPACE}
spec:
  managementState: Managed
  storageSize: 1Gi
  storage:
    secret:
      type: s3
      name: tempostack-dev-minio
  tenants:
    mode: openshift
    authentication:
    - tenantName: ${TEMPO_TENANT}
      tenantId: a1b2c3d4-e5f6-7890-abcd-ef1234567890
  template:
    gateway:
      enabled: true
EOF

  wait_for "TempoStack gateway service" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} get svc tempo-${TEMPO_STACK_NAME}-gateway -n ${TEMPO_NAMESPACE}"

  # RBAC
  local REMOTE_COLLECTOR_NAME="otel-remote-${SPOKE_TWO_CLUSTER_NAME}"

  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: tempostack-traces-write
rules:
- apiGroups:
  - tempo.grafana.com
  resources:
  - ${TEMPO_TENANT}
  resourceNames:
  - traces
  verbs:
  - create
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tempostack-traces-write-collectors
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tempostack-traces-write
subjects:
- kind: ServiceAccount
  name: otel-collector
  namespace: istio-system
- kind: ServiceAccount
  name: ${REMOTE_COLLECTOR_NAME}-collector
  namespace: istio-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: tempostack-traces-reader-${TEMPO_TENANT}
rules:
- apiGroups:
  - tempo.grafana.com
  resources:
  - ${TEMPO_TENANT}
  resourceNames:
  - traces
  verbs:
  - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tempostack-traces-reader-${TEMPO_TENANT}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tempostack-traces-reader-${TEMPO_TENANT}
subjects:
- kind: Group
  apiGroup: rbac.authorization.k8s.io
  name: system:authenticated
EOF

  # Local OTEL collector on spoke
  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: opentelemetry.io/v1beta1
kind: OpenTelemetryCollector
metadata:
  name: otel
  namespace: istio-system
spec:
  mode: deployment
  replicas: 1
  config:
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
    extensions:
      bearertokenauth:
        filename: /var/run/secrets/kubernetes.io/serviceaccount/token
    processors:
      batch: {}
      resource:
        attributes:
        - key: k8s.cluster.name
          action: upsert
          value: ${SPOKE_CLUSTER_NAME}
    exporters:
      otlp_http/tempo:
        auth:
          authenticator: bearertokenauth
        endpoint: https://tempo-${TEMPO_STACK_NAME}-gateway.${TEMPO_NAMESPACE}.svc.cluster.local:8080/api/traces/v1/${TEMPO_TENANT}
        headers:
          X-Scope-OrgID: ${TEMPO_TENANT}
        tls:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt
    service:
      extensions:
      - bearertokenauth
      pipelines:
        traces:
          receivers:
          - otlp
          processors:
          - resource
          - batch
          exporters:
          - otlp_http/tempo
EOF

  wait_for "Local OTEL collector ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} rollout status deployment/otel-collector -n istio-system --timeout=10s"

  # Remote receiver on spoke with mTLS
  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: opentelemetry.io/v1beta1
kind: OpenTelemetryCollector
metadata:
  name: ${REMOTE_COLLECTOR_NAME}
  namespace: istio-system
spec:
  mode: deployment
  replicas: 1
  volumeMounts:
  - name: server-certs
    mountPath: /etc/otel/server
    readOnly: true
  - name: ca-cert
    mountPath: /etc/otel/ca
    readOnly: true
  volumes:
  - name: server-certs
    secret:
      secretName: ${REMOTE_COLLECTOR_NAME}-server-tls
  - name: ca-cert
    secret:
      secretName: ${REMOTE_COLLECTOR_NAME}-ca
  config:
    receivers:
      otlp:
        protocols:
          http:
            endpoint: 0.0.0.0:4318
            tls:
              cert_file: /etc/otel/server/tls.crt
              key_file: /etc/otel/server/tls.key
              client_ca_file: /etc/otel/ca/tls.crt
    processors:
      batch: {}
      resource:
        attributes:
        - key: receiving.cluster
          action: upsert
          value: ${SPOKE_CLUSTER_NAME}
        - key: source.cluster
          action: upsert
          value: ${SPOKE_TWO_CLUSTER_NAME}
    extensions:
      bearertokenauth:
        filename: /var/run/secrets/kubernetes.io/serviceaccount/token
    exporters:
      otlp_http/tempo:
        auth:
          authenticator: bearertokenauth
        endpoint: https://tempo-${TEMPO_STACK_NAME}-gateway.${TEMPO_NAMESPACE}.svc.cluster.local:8080/api/traces/v1/${TEMPO_TENANT}
        headers:
          X-Scope-OrgID: ${TEMPO_TENANT}
        tls:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt
    service:
      extensions:
      - bearertokenauth
      pipelines:
        traces:
          receivers:
          - otlp
          processors:
          - resource
          - batch
          exporters:
          - otlp_http/tempo
EOF

  # Create Route for remote receiver
  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: ${REMOTE_COLLECTOR_NAME}
  namespace: istio-system
spec:
  to:
    kind: Service
    name: ${REMOTE_COLLECTOR_NAME}-collector
    weight: 100
  port:
    targetPort: otlp-http
  tls:
    termination: passthrough
  wildcardPolicy: None
EOF

  local REMOTE_ROUTE_HOST=""
  wait_for "Remote receiver Route hostname" "${TIMEOUT}" \
    "[ -n \"\$(oc --context=${SPOKE_CTX} get route ${REMOTE_COLLECTOR_NAME} -n istio-system -o jsonpath='{.spec.host}' 2>/dev/null)\" ]"
  REMOTE_ROUTE_HOST=$(oc --context="${SPOKE_CTX}" get route "${REMOTE_COLLECTOR_NAME}" -n istio-system -o jsonpath='{.spec.host}')
  info "Remote receiver Route: https://${REMOTE_ROUTE_HOST}"

  # Generate mTLS certs
  local OTEL_CERT_DIR="${TMP_DIR}/otel-mtls"
  mkdir -p "${OTEL_CERT_DIR}"

  openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 -days 3650 -nodes \
    -keyout "${OTEL_CERT_DIR}/ca.key" -out "${OTEL_CERT_DIR}/ca.crt" \
    -subj "/CN=${REMOTE_COLLECTOR_NAME}-ca" 2>/dev/null

  openssl req -newkey ec -pkeyopt ec_paramgen_curve:P-256 -nodes \
    -keyout "${OTEL_CERT_DIR}/server.key" -out "${OTEL_CERT_DIR}/server.csr" \
    -subj "/CN=${REMOTE_COLLECTOR_NAME}-server" 2>/dev/null

  printf "subjectAltName=DNS:%s,DNS:%s.istio-system.svc,DNS:%s.istio-system.svc.cluster.local,DNS:%s" \
    "${REMOTE_COLLECTOR_NAME}-collector" \
    "${REMOTE_COLLECTOR_NAME}-collector" \
    "${REMOTE_COLLECTOR_NAME}-collector" \
    "${REMOTE_ROUTE_HOST}" > "${OTEL_CERT_DIR}/server-ext.cnf"

  openssl x509 -req -days 3650 -in "${OTEL_CERT_DIR}/server.csr" \
    -CA "${OTEL_CERT_DIR}/ca.crt" -CAkey "${OTEL_CERT_DIR}/ca.key" -CAcreateserial \
    -extfile "${OTEL_CERT_DIR}/server-ext.cnf" -out "${OTEL_CERT_DIR}/server.crt" 2>/dev/null

  openssl req -newkey ec -pkeyopt ec_paramgen_curve:P-256 -nodes \
    -keyout "${OTEL_CERT_DIR}/client.key" -out "${OTEL_CERT_DIR}/client.csr" \
    -subj "/CN=${REMOTE_COLLECTOR_NAME}-client" 2>/dev/null

  openssl x509 -req -days 3650 -in "${OTEL_CERT_DIR}/client.csr" \
    -CA "${OTEL_CERT_DIR}/ca.crt" -CAkey "${OTEL_CERT_DIR}/ca.key" -CAcreateserial \
    -out "${OTEL_CERT_DIR}/client.crt" 2>/dev/null

  # Load certs into secrets
  oc --context="${SPOKE_CTX}" create secret generic "${REMOTE_COLLECTOR_NAME}-ca" -n istio-system \
    --from-file=tls.crt="${OTEL_CERT_DIR}/ca.crt" --from-file=tls.key="${OTEL_CERT_DIR}/ca.key" \
    --dry-run=client -o yaml | oc --context="${SPOKE_CTX}" apply -f -

  oc --context="${SPOKE_CTX}" create secret tls "${REMOTE_COLLECTOR_NAME}-server-tls" -n istio-system \
    --cert="${OTEL_CERT_DIR}/server.crt" --key="${OTEL_CERT_DIR}/server.key" \
    --dry-run=client -o yaml | oc --context="${SPOKE_CTX}" apply -f -

  oc --context="${SPOKE_CTX}" create secret tls "${REMOTE_COLLECTOR_NAME}-client-tls" -n istio-system \
    --cert="${OTEL_CERT_DIR}/client.crt" --key="${OTEL_CERT_DIR}/client.key" \
    --dry-run=client -o yaml | oc --context="${SPOKE_CTX}" apply -f -

  # Restart remote collector to pick up certs
  wait_for "Remote collector deployment exists" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} get deployment ${REMOTE_COLLECTOR_NAME}-collector -n istio-system"

  oc --context="${SPOKE_CTX}" rollout restart "deployment/${REMOTE_COLLECTOR_NAME}-collector" -n istio-system

  wait_for "Remote receiver collector ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} rollout status deployment/${REMOTE_COLLECTOR_NAME}-collector -n istio-system --timeout=10s"

  # Remote forwarder on spoke-two
  local REMOTE_MTLS_CLIENT_BUNDLE="${REMOTE_COLLECTOR_NAME}-client-bundle"

  local CA_BUNDLE CLIENT_CRT CLIENT_KEY
  CA_BUNDLE=$(oc --context="${SPOKE_CTX}" get secret "${REMOTE_COLLECTOR_NAME}-ca" -n istio-system -o jsonpath='{.data.tls\.crt}' | base64 -d)
  CLIENT_CRT=$(oc --context="${SPOKE_CTX}" get secret "${REMOTE_COLLECTOR_NAME}-client-tls" -n istio-system -o jsonpath='{.data.tls\.crt}' | base64 -d)
  CLIENT_KEY=$(oc --context="${SPOKE_CTX}" get secret "${REMOTE_COLLECTOR_NAME}-client-tls" -n istio-system -o jsonpath='{.data.tls\.key}' | base64 -d)

  oc --context="${SPOKE_TWO_CTX}" create secret generic "${REMOTE_MTLS_CLIENT_BUNDLE}" -n istio-system \
    --from-literal=ca.crt="${CA_BUNDLE}" --from-literal=tls.crt="${CLIENT_CRT}" --from-literal=tls.key="${CLIENT_KEY}" \
    --dry-run=client -o yaml | oc --context="${SPOKE_TWO_CTX}" apply -f -

  oc --context="${SPOKE_TWO_CTX}" apply -f - <<EOF
apiVersion: opentelemetry.io/v1beta1
kind: OpenTelemetryCollector
metadata:
  name: otel
  namespace: istio-system
spec:
  mode: deployment
  replicas: 1
  volumeMounts:
  - name: mtls-bundle
    mountPath: /etc/otel/mtls
    readOnly: true
  volumes:
  - name: mtls-bundle
    secret:
      secretName: ${REMOTE_MTLS_CLIENT_BUNDLE}
  config:
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
    processors:
      batch: {}
      resource:
        attributes:
        - key: k8s.cluster.name
          action: upsert
          value: ${SPOKE_TWO_CLUSTER_NAME}
    exporters:
      otlp_http/central:
        endpoint: https://${REMOTE_ROUTE_HOST}
        tls:
          cert_file: /etc/otel/mtls/tls.crt
          key_file: /etc/otel/mtls/tls.key
          ca_file: /etc/otel/mtls/ca.crt
    service:
      pipelines:
        traces:
          receivers:
          - otlp
          processors:
          - resource
          - batch
          exporters:
          - otlp_http/central
EOF

  wait_for "Spoke-two forwarder ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} rollout status deployment/otel-collector -n istio-system --timeout=10s"

  # Configure Istio tracing on both clusters
  for CTX in "${SPOKE_CTX}" "${SPOKE_TWO_CTX}"; do
    oc --context="${CTX}" patch istio default --type=merge -p '{
      "spec": {
        "values": {
          "meshConfig": {
            "enableTracing": true,
            "extensionProviders": [
              {
                "name": "otel-tracing",
                "opentelemetry": {
                  "service": "otel-collector.istio-system.svc.cluster.local",
                  "port": 4317
                }
              }
            ]
          }
        }
      }
    }'

    oc --context="${CTX}" apply -f - <<'EOF'
apiVersion: telemetry.istio.io/v1
kind: Telemetry
metadata:
  name: otel-tracing
  namespace: istio-system
spec:
  tracing:
  - providers:
    - name: otel-tracing
    randomSamplingPercentage: 100
EOF

    for NS in ambient-demo bookinfo; do
      if oc --context="${CTX}" get namespace "${NS}" &>/dev/null; then
        oc --context="${CTX}" apply -f - <<EOF
apiVersion: telemetry.istio.io/v1
kind: Telemetry
metadata:
  name: ${NS}-tracing
  namespace: ${NS}
spec:
  tracing:
  - providers:
    - name: otel-tracing
    randomSamplingPercentage: 100
EOF
      fi
    done
  done

  # Restart waypoints for tracing
  for NS in ambient-demo; do
    for CTX in "${SPOKE_CTX}" "${SPOKE_TWO_CTX}"; do
      if oc --context="${CTX}" get deployment waypoint -n "${NS}" &>/dev/null 2>&1; then
        oc --context="${CTX}" rollout restart deployment/waypoint -n "${NS}"
      fi
    done
  done

  # Distributed tracing console plugin
  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: observability.openshift.io/v1alpha1
kind: UIPlugin
metadata:
  name: distributed-tracing
spec:
  type: DistributedTracing
EOF

  wait_for "Distributed tracing plugin reconciled" "${TIMEOUT}" \
    "[ \"\$(oc --context=${SPOKE_CTX} get uiplugin distributed-tracing -o jsonpath='{.status.conditions[?(@.type==\"Reconciled\")].status}' 2>/dev/null)\" = 'True' ]"

  # Configure Kiali for Tempo
  local CONSOLE_URL
  CONSOLE_URL=$(oc --context="${SPOKE_CTX}" get route console -n openshift-console -o jsonpath='https://{.spec.host}')

  oc --context="${SPOKE_CTX}" patch kiali kiali -n istio-system --type=merge -p "{
    \"spec\": {
      \"external_services\": {
        \"tracing\": {
          \"enabled\": true,
          \"provider\": \"tempo\",
          \"use_grpc\": false,
          \"internal_url\": \"https://tempo-${TEMPO_STACK_NAME}-gateway.${TEMPO_NAMESPACE}.svc.cluster.local:8080/\",
          \"external_url\": \"${CONSOLE_URL}\",
          \"auth\": {
            \"type\": \"bearer\",
            \"use_kiali_token\": true
          },
          \"tempo_config\": {
            \"name\": \"${TEMPO_STACK_NAME}\",
            \"namespace\": \"${TEMPO_NAMESPACE}\",
            \"tenant\": \"${TEMPO_TENANT}\",
            \"org_id\": \"${TEMPO_TENANT}\",
            \"url_format\": \"openshift\"
          }
        }
      }
    }
  }"

  wait_for "Kiali rollout after Tempo config" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} rollout status deployment/kiali -n istio-system --timeout=10s"
}

guide3_verification() {
  info "=== Guide 3 Verification ==="

  wait_for "OTEL collectors running on spoke" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} get pods -n istio-system -l app.kubernetes.io/managed-by=opentelemetry-operator --no-headers | grep -q Running"

  wait_for "OTEL forwarder running on spoke-two" "${TIMEOUT}" \
    "oc --context=${SPOKE_TWO_CTX} get pods -n istio-system -l app.kubernetes.io/managed-by=opentelemetry-operator --no-headers | grep -q Running"

  info "Guide 3 verification passed - Perses and Tempo deployed"
}

# =============================================================================
# Guide 4: Health Status Alerts
# =============================================================================

guide4_phase2_health_metrics() {
  info "=== Guide 4 Phase 2: Enable Health Status Metrics ==="

  local KIALI_CR_NS
  KIALI_CR_NS=$(oc --context="${SPOKE_CTX}" get kiali -A -o jsonpath='{.items[0].metadata.namespace}')

  oc --context="${SPOKE_CTX}" patch kiali kiali -n "${KIALI_CR_NS}" --type=merge -p '
spec:
  server:
    observability:
      metrics:
        enabled: true
        health_status:
          enabled: true
'

  wait_for "Kiali CR reconciled after health metrics" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait kiali kiali -n ${KIALI_CR_NS} --for=condition=Successful --timeout=10s"
}

guide4_phase3_servicemonitor() {
  info "=== Guide 4 Phase 3: ServiceMonitor for Kiali ==="

  local KIALI_NS
  KIALI_NS=$(oc --context="${SPOKE_CTX}" get kiali -A -o jsonpath='{.items[0].spec.deployment.namespace}')

  wait_for "Kiali CA bundle ConfigMap ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} get configmap kiali-cabundle-openshift -n ${KIALI_NS} -o jsonpath='{.data.service-ca\\.crt}' | grep -q ."

  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: kiali
  namespace: ${KIALI_NS}
spec:
  endpoints:
  - interval: 30s
    port: tcp-metrics
    scheme: https
    tlsConfig:
      ca:
        configMap:
          key: service-ca.crt
          name: kiali-cabundle-openshift
      serverName: kiali.${KIALI_NS}.svc
  namespaceSelector:
    matchNames:
    - ${KIALI_NS}
  selector:
    matchLabels:
      app.kubernetes.io/name: kiali
EOF
}

guide4_phase4_recording_rules() {
  info "=== Guide 4 Phase 4: Recording Rules and Alerts ==="

  local KIALI_NS
  KIALI_NS=$(oc --context="${SPOKE_CTX}" get kiali -A -o jsonpath='{.items[0].spec.deployment.namespace}')

  oc --context="${SPOKE_CTX}" apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kiali-health-status
  namespace: ${KIALI_NS}
  labels:
    openshift.io/prometheus-rule-evaluation-scope: leaf-prometheus
spec:
  groups:
  - name: kiali.health.recording
    rules:
    - record: kiali:health_status:max
      expr: |
        max by (cluster, exported_namespace, health_type, name) (kiali_health_status)
    - record: kiali:health_status:namespace_max
      expr: |
        max by (cluster, exported_namespace, name) (
          kiali_health_status{health_type="namespace"}
        )
  - name: kiali.health.alerts
    rules:
    - alert: KialiHealthFailure
      expr: |
        kiali:health_status:max{health_type=~"app|service|workload"} == 3
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: >-
          {{ \$labels.health_type }} {{ \$labels.name }} in {{ \$labels.exported_namespace }}
          (cluster {{ \$labels.cluster }}) is in Failure
        description: >-
          Kiali reported Failure (kiali_health_status == 3) for at least 5 minutes.
    - alert: KialiHealthDegraded
      expr: |
        kiali:health_status:max{health_type=~"app|service|workload"} == 2
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: >-
          {{ \$labels.health_type }} {{ \$labels.name }} in {{ \$labels.exported_namespace }}
          (cluster {{ \$labels.cluster }}) is Degraded
        description: >-
          Kiali reported Degraded (kiali_health_status == 2) for at least 10 minutes.
    - alert: KialiNamespaceHealthFailure
      expr: |
        kiali:health_status:namespace_max == 3
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: >-
          Namespace {{ \$labels.exported_namespace }} (cluster {{ \$labels.cluster }})
          is in Failure
        description: >-
          Kiali namespace aggregate health status is Failure (kiali_health_status == 3)
          for at least 5 minutes.
EOF
}

guide4_phase6_acm_hub_alerts() {
  info "=== Guide 4 Phase 6: ACM Hub Alerts ==="

  # Ensure placement is selected (may already be set if Guide 1 ran in the same session)
  select_mcoa_placement

  # Create MCOA health federation resources for kiali_health_status
  create_kiali_health_federation_resources

  # Create hub Thanos Ruler rules
  oc --context="${HUB_CTX}" apply -f - <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: thanos-ruler-custom-rules
  namespace: open-cluster-management-observability
data:
  custom_rules.yaml: |
    groups:
    - name: kiali.health.hub.alerts
      rules:
      - alert: KialiHubHealthFailure
        expr: |
          max by (cluster, exported_namespace, health_type, name) (
            kiali_health_status{health_type=~"app|service|workload"}
          ) == 3
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: >-
            {{ $labels.health_type }} {{ $labels.name }} in {{ $labels.exported_namespace }}
            (cluster {{ $labels.cluster }}) has Failure health status
          description: >-
            Hub Thanos Ruler: Kiali reported Failure (kiali_health_status == 3)
            for at least 5 minutes.
      - alert: KialiHubHealthDegraded
        expr: |
          max by (cluster, exported_namespace, health_type, name) (
            kiali_health_status{health_type=~"app|service|workload"}
          ) == 2
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: >-
            {{ $labels.health_type }} {{ $labels.name }} in {{ $labels.exported_namespace }}
            (cluster {{ $labels.cluster }}) has Degraded health status
          description: >-
            Hub Thanos Ruler: Kiali reported Degraded (kiali_health_status == 2)
            for at least 10 minutes.
      - alert: KialiHubNamespaceHealthFailure
        expr: |
          max by (cluster, exported_namespace, name) (
            kiali_health_status{health_type="namespace"}
          ) == 3
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: >-
            Namespace {{ $labels.exported_namespace }} (cluster {{ $labels.cluster }})
            has Failure health status
          description: >-
            Hub Thanos Ruler: Kiali namespace aggregate health status is Failure
            (kiali_health_status == 3) for at least 5 minutes.
EOF
}

guide4_phase7_netobserv() {
  info "=== Guide 4 Phase 7: NetObserv Network Health ==="

  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-netobserv-operator
  labels:
    openshift.io/cluster-monitoring: "true"
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-netobserv-operator
  namespace: openshift-netobserv-operator
spec: {}
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: netobserv-operator
  namespace: openshift-netobserv-operator
spec:
  channel: stable
  installPlanApproval: Automatic
  name: netobserv-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

  wait_for "FlowCollector CRD" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} get crd flowcollectors.flows.netobserv.io"

  wait_for "NetObserv operator ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait pod --for=condition=Ready -l app=netobserv-operator -n openshift-netobserv-operator --timeout=10s"

  oc --context="${SPOKE_CTX}" apply -f - <<'EOF'
apiVersion: flows.netobserv.io/v1beta2
kind: FlowCollector
metadata:
  name: cluster
spec:
  namespace: netobserv
  agent:
    type: eBPF
  loki:
    enable: false
  consolePlugin:
    enable: true
EOF

  wait_for "FlowCollector ready" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} wait flowcollector/cluster --for=condition=Ready --timeout=10s"

  # Re-apply PrometheusRule with NetObserv annotations
  local KIALI_NS
  KIALI_NS=$(oc --context="${SPOKE_CTX}" get kiali -A -o jsonpath='{.items[0].spec.deployment.namespace}')

  oc --context="${SPOKE_CTX}" apply --server-side --force-conflicts -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kiali-health-status
  namespace: ${KIALI_NS}
  labels:
    netobserv: "true"
    openshift.io/prometheus-rule-evaluation-scope: leaf-prometheus
  annotations:
    netobserv.io/network-health: |
      {
        "kiali:health_status:max": {
          "summary": "Kiali health status for {{ \$labels.health_type }} {{ \$labels.name }} in {{ \$labels.exported_namespace }} is {{ \$value }}",
          "description": "Worst Kiali health score (0=Healthy, 1=Not Ready, 2=Degraded, 3=Failure) for the entity.",
          "netobserv_io_network_health": "{\"unit\":\"status\",\"upperBound\":\"3\",\"namespaceLabels\":[\"exported_namespace\"],\"recordingThresholds\":{\"info\":\"1\",\"warning\":\"2\",\"critical\":\"3\"}}"
        },
        "kiali:health_status:namespace_max": {
          "summary": "Kiali namespace health for {{ \$labels.exported_namespace }} is {{ \$value }}",
          "description": "Worst Kiali namespace aggregate health score (0=Healthy, 1=Not Ready, 2=Degraded, 3=Failure).",
          "netobserv_io_network_health": "{\"unit\":\"status\",\"upperBound\":\"3\",\"namespaceLabels\":[\"exported_namespace\"],\"recordingThresholds\":{\"info\":\"1\",\"warning\":\"2\",\"critical\":\"3\"}}"
        }
      }
spec:
  groups:
  - name: kiali.health.recording
    rules:
    - record: kiali:health_status:max
      expr: |
        max by (cluster, exported_namespace, health_type, name) (kiali_health_status)
      labels:
        netobserv: "true"
    - record: kiali:health_status:namespace_max
      expr: |
        max by (cluster, exported_namespace, name) (
          kiali_health_status{health_type="namespace"}
        )
      labels:
        netobserv: "true"
  - name: kiali.health.alerts
    rules:
    - alert: KialiHealthFailure
      expr: |
        kiali:health_status:max{health_type=~"app|service|workload"} == 3
      for: 5m
      labels:
        netobserv: "true"
        severity: critical
      annotations:
        summary: >-
          {{ \$labels.health_type }} {{ \$labels.name }} in {{ \$labels.exported_namespace }}
          (cluster {{ \$labels.cluster }}) is in Failure
        description: >-
          Kiali reported Failure (kiali_health_status == 3) for at least 5 minutes.
        netobserv_io_network_health: '{"namespaceLabels":["exported_namespace"],"threshold":"3","unit":"status","upperBound":"3"}'
    - alert: KialiHealthDegraded
      expr: |
        kiali:health_status:max{health_type=~"app|service|workload"} == 2
      for: 10m
      labels:
        netobserv: "true"
        severity: warning
      annotations:
        summary: >-
          {{ \$labels.health_type }} {{ \$labels.name }} in {{ \$labels.exported_namespace }}
          (cluster {{ \$labels.cluster }}) is Degraded
        description: >-
          Kiali reported Degraded (kiali_health_status == 2) for at least 10 minutes.
        netobserv_io_network_health: '{"namespaceLabels":["exported_namespace"],"threshold":"2","unit":"status","upperBound":"3"}'
    - alert: KialiNamespaceHealthFailure
      expr: |
        kiali:health_status:namespace_max == 3
      for: 5m
      labels:
        netobserv: "true"
        severity: critical
      annotations:
        summary: >-
          Namespace {{ \$labels.exported_namespace }} (cluster {{ \$labels.cluster }})
          is in Failure
        description: >-
          Kiali namespace aggregate health status is Failure (kiali_health_status == 3)
          for at least 5 minutes.
        netobserv_io_network_health: '{"namespaceLabels":["exported_namespace"],"threshold":"3","unit":"status","upperBound":"3"}'
EOF
}

guide4_verification() {
  info "=== Guide 4 Verification ==="

  local KIALI_NS
  KIALI_NS=$(oc --context="${SPOKE_CTX}" get kiali -A -o jsonpath='{.items[0].spec.deployment.namespace}')

  wait_for "kiali_health_status metric scraped by UWM" "${TIMEOUT}" \
    "oc --context=${SPOKE_CTX} get prometheusrule kiali-health-status -n ${KIALI_NS}"

  info "Guide 4 verification passed - health status alerts configured"
}

# =============================================================================
# Cleanup functions (reverse order, ignoring failures)
# =============================================================================

cleanup_guide4() {
  info "=== Cleanup Guide 4 ==="

  local KIALI_NS KIALI_CR_NS
  KIALI_NS=$(oc --context="${SPOKE_CTX}" get kiali -A -o jsonpath='{.items[0].spec.deployment.namespace}' 2>/dev/null || echo "istio-system")
  KIALI_CR_NS=$(oc --context="${SPOKE_CTX}" get kiali -A -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null || echo "istio-system")

  # NetObserv cleanup
  oc --context="${SPOKE_CTX}" delete flowcollector cluster --ignore-not-found
  oc --context="${SPOKE_CTX}" wait flowcollector/cluster --for=delete --timeout=120s 2>/dev/null || true
  oc --context="${SPOKE_CTX}" delete namespace netobserv --ignore-not-found
  oc --context="${SPOKE_CTX}" delete subscription netobserv-operator -n openshift-netobserv-operator --ignore-not-found
  oc --context="${SPOKE_CTX}" delete installplan --all -n openshift-netobserv-operator --ignore-not-found
  oc --context="${SPOKE_CTX}" delete csv -n openshift-netobserv-operator --all --ignore-not-found
  oc --context="${SPOKE_CTX}" delete operatorgroup openshift-netobserv-operator -n openshift-netobserv-operator --ignore-not-found
  oc --context="${SPOKE_CTX}" delete namespace openshift-netobserv-operator --ignore-not-found
  oc --context="${SPOKE_CTX}" delete consoleplugin netobserv-plugin-static --ignore-not-found
  for suffix in flows.netobserv.io; do
    local CRDS
    CRDS=$(oc --context="${SPOKE_CTX}" get crd --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | grep "\.${suffix}$" || true)
    [ -n "${CRDS}" ] && echo "${CRDS}" | xargs oc --context="${SPOKE_CTX}" delete crd --ignore-not-found
  done

  # Remove NetObserv operator ClusterRoles/Bindings
  local NETOBSERV_CRS
  NETOBSERV_CRS=$(oc --context="${SPOKE_CTX}" get clusterrole --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | grep "^netobserv-" || true)
  [ -n "${NETOBSERV_CRS}" ] && echo "${NETOBSERV_CRS}" | xargs oc --context="${SPOKE_CTX}" delete clusterrole --ignore-not-found
  local NETOBSERV_CRBS
  NETOBSERV_CRBS=$(oc --context="${SPOKE_CTX}" get clusterrolebinding --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | grep "^netobserv-" || true)
  [ -n "${NETOBSERV_CRBS}" ] && echo "${NETOBSERV_CRBS}" | xargs oc --context="${SPOKE_CTX}" delete clusterrolebinding --ignore-not-found

  # PrometheusRules and ServiceMonitor
  oc --context="${SPOKE_CTX}" delete prometheusrule kiali-health-status -n "${KIALI_NS}" --ignore-not-found
  oc --context="${SPOKE_CTX}" delete servicemonitor kiali -n "${KIALI_NS}" --ignore-not-found

  # Disable health-status metric
  oc --context="${SPOKE_CTX}" patch kiali kiali -n "${KIALI_CR_NS}" --type=merge -p '
spec:
  server:
    observability:
      metrics:
        health_status:
          enabled: false
' 2>/dev/null || true

  # Hub cleanup — remove MCOA health federation placement refs and configuration resources
  remove_mcoa_ref monitoring.rhobs scrapeconfigs kiali-health-federation 2>/dev/null || true
  remove_mcoa_ref monitoring.coreos.com prometheusrules kiali-health-aggregation 2>/dev/null || true
  oc --context="${HUB_CTX}" delete scrapeconfig kiali-health-federation \
    -n open-cluster-management-observability --ignore-not-found
  oc --context="${HUB_CTX}" delete prometheusrule kiali-health-aggregation \
    -n open-cluster-management-observability --ignore-not-found

  oc --context="${HUB_CTX}" -n open-cluster-management-observability \
    delete configmap thanos-ruler-custom-rules --ignore-not-found
}

cleanup_guide3() {
  info "=== Cleanup Guide 3 ==="

  local REMOTE_COLLECTOR_NAME="otel-remote-${SPOKE_TWO_CLUSTER_NAME}"
  local REMOTE_MTLS_CLIENT_BUNDLE="${REMOTE_COLLECTOR_NAME}-client-bundle"

  # Revert Kiali Perses and tracing config
  oc --context="${SPOKE_CTX}" patch kiali kiali -n istio-system --type=json \
    -p '[{"op":"remove","path":"/spec/external_services/perses"}]' 2>/dev/null || true
  oc --context="${SPOKE_CTX}" patch kiali kiali -n istio-system --type=json \
    -p '[{"op":"remove","path":"/spec/external_services/tracing"}]' 2>/dev/null || true

  # Remove UIPlugins
  oc --context="${SPOKE_CTX}" delete uiplugin monitoring --ignore-not-found
  oc --context="${SPOKE_CTX}" delete uiplugin distributed-tracing --ignore-not-found

  # Remove Perses resources (dynamically find COO namespace where Perses lives)
  local COO_NS
  COO_NS=$(oc --context="${SPOKE_CTX}" get subscriptions.operators.coreos.com -A -o json 2>/dev/null | \
    jq -r '[.items[] | select(.spec.name == "cluster-observability-operator")][0] |
      select(. != null) | .metadata.namespace' 2>/dev/null || echo "openshift-cluster-observability-operator")
  oc --context="${SPOKE_CTX}" delete persesdashboard --all -n perses --ignore-not-found
  oc --context="${SPOKE_CTX}" delete persesdatasource --all -n perses --ignore-not-found
  oc --context="${SPOKE_CTX}" delete perses perses -n "${COO_NS}" --ignore-not-found
  oc --context="${SPOKE_CTX}" delete configmap perses-acm-server-ca -n "${COO_NS}" --ignore-not-found
  oc --context="${SPOKE_CTX}" delete secret perses-acm-client-certs -n "${COO_NS}" --ignore-not-found
  oc --context="${SPOKE_CTX}" delete namespace perses --ignore-not-found

  # Remove Telemetry CRs and tracing from Istio
  for CTX in "${SPOKE_CTX}" "${SPOKE_TWO_CTX}"; do
    oc --context="${CTX}" delete telemetry otel-tracing -n istio-system --ignore-not-found
    for NS in ambient-demo bookinfo; do
      oc --context="${CTX}" delete telemetry "${NS}-tracing" -n "${NS}" --ignore-not-found
    done
    oc --context="${CTX}" patch istio default --type=json \
      -p '[{"op":"remove","path":"/spec/values/meshConfig/extensionProviders"},{"op":"remove","path":"/spec/values/meshConfig/enableTracing"}]' 2>/dev/null || true
  done

  # Remove spoke-two forwarder
  oc --context="${SPOKE_TWO_CTX}" delete opentelemetrycollector otel -n istio-system --ignore-not-found
  oc --context="${SPOKE_TWO_CTX}" wait opentelemetrycollector/otel -n istio-system --for=delete --timeout=120s 2>/dev/null || true
  oc --context="${SPOKE_TWO_CTX}" delete secret "${REMOTE_MTLS_CLIENT_BUNDLE}" -n istio-system --ignore-not-found

  # Remove spoke collectors and certs
  oc --context="${SPOKE_CTX}" delete opentelemetrycollector otel "${REMOTE_COLLECTOR_NAME}" -n istio-system --ignore-not-found
  oc --context="${SPOKE_CTX}" wait opentelemetrycollector -n istio-system --for=delete --all --timeout=120s 2>/dev/null || true
  oc --context="${SPOKE_CTX}" delete route "${REMOTE_COLLECTOR_NAME}" -n istio-system --ignore-not-found
  oc --context="${SPOKE_CTX}" delete secret "${REMOTE_COLLECTOR_NAME}-ca" "${REMOTE_COLLECTOR_NAME}-server-tls" "${REMOTE_COLLECTOR_NAME}-client-tls" -n istio-system --ignore-not-found
  oc --context="${SPOKE_CTX}" delete clusterrolebinding tempostack-traces-write-collectors "tempostack-traces-reader-${TEMPO_TENANT}" --ignore-not-found
  oc --context="${SPOKE_CTX}" delete clusterrole tempostack-traces-write "tempostack-traces-reader-${TEMPO_TENANT}" --ignore-not-found

  # Remove TempoStack
  oc --context="${SPOKE_CTX}" delete tempostack "${TEMPO_STACK_NAME}" -n "${TEMPO_NAMESPACE}" --ignore-not-found
  oc --context="${SPOKE_CTX}" wait "tempostack/${TEMPO_STACK_NAME}" -n "${TEMPO_NAMESPACE}" --for=delete --timeout=120s 2>/dev/null || true
  oc --context="${SPOKE_CTX}" delete deployment minio -n "${TEMPO_NAMESPACE}" --ignore-not-found
  oc --context="${SPOKE_CTX}" delete pvc minio-pv-claim -n "${TEMPO_NAMESPACE}" --ignore-not-found
  oc --context="${SPOKE_CTX}" delete secret tempostack-dev-minio -n "${TEMPO_NAMESPACE}" --ignore-not-found
  oc --context="${SPOKE_CTX}" delete namespace "${TEMPO_NAMESPACE}" --ignore-not-found

  # Remove operators (all CRs above must be gone before this point)
  for CTX in "${SPOKE_CTX}" "${SPOKE_TWO_CTX}"; do
    oc --context="${CTX}" delete subscriptions.operators.coreos.com opentelemetry-product -n openshift-operators --ignore-not-found
  done
  oc --context="${SPOKE_CTX}" delete subscriptions.operators.coreos.com tempo-product -n openshift-operators --ignore-not-found

  for CTX in "${SPOKE_CTX}" "${SPOKE_TWO_CTX}"; do
    oc --context="${CTX}" delete installplan -n openshift-operators --all --ignore-not-found
    local CSV
    CSV=$(oc --context="${CTX}" get csv -n openshift-operators -l operators.coreos.com/opentelemetry-product.openshift-operators --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | head -1)
    [ -n "${CSV}" ] && oc --context="${CTX}" delete csv "${CSV}" -n openshift-operators --ignore-not-found
  done

  local CSV
  CSV=$(oc --context="${SPOKE_CTX}" get csv -n openshift-operators -l operators.coreos.com/tempo-product.openshift-operators --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | head -1)
  [ -n "${CSV}" ] && oc --context="${SPOKE_CTX}" delete csv "${CSV}" -n openshift-operators --ignore-not-found

  # Remove CRDs (only OpenTelemetry, Tempo, and Perses — NOT monitoring.rhobs which belongs to COO)
  for CTX in "${SPOKE_CTX}" "${SPOKE_TWO_CTX}"; do
    local CRDS
    CRDS=$(oc --context="${CTX}" get crd --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | grep "\.opentelemetry\.io$" || true)
    [ -n "${CRDS}" ] && echo "${CRDS}" | xargs oc --context="${CTX}" delete crd --ignore-not-found
  done
  for suffix in tempo.grafana.com perses.dev; do
    local CRDS
    CRDS=$(oc --context="${SPOKE_CTX}" get crd --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | grep "\.${suffix}$" || true)
    [ -n "${CRDS}" ] && echo "${CRDS}" | xargs oc --context="${SPOKE_CTX}" delete crd --ignore-not-found
  done

  # Remove the ClusterRole installed by the OpenTelemetry Operator on each spoke.
  for CTX in "${SPOKE_CTX}" "${SPOKE_TWO_CTX}"; do
    oc --context="${CTX}" delete clusterrole opentelemetry-operator-metrics-reader --ignore-not-found
  done

  # Remove Perses and Tempo operator ClusterRoles/Bindings
  local PERSES_CRS
  PERSES_CRS=$(oc --context="${SPOKE_CTX}" get clusterrole --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | grep -E "^perses" || true)
  [ -n "${PERSES_CRS}" ] && echo "${PERSES_CRS}" | xargs oc --context="${SPOKE_CTX}" delete clusterrole --ignore-not-found
  local TEMPO_CRS
  TEMPO_CRS=$(oc --context="${SPOKE_CTX}" get clusterrole --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | grep "^tempo-operator" || true)
  [ -n "${TEMPO_CRS}" ] && echo "${TEMPO_CRS}" | xargs oc --context="${SPOKE_CTX}" delete clusterrole --ignore-not-found
  local TEMPO_CRBS
  TEMPO_CRBS=$(oc --context="${SPOKE_CTX}" get clusterrolebinding --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | grep "^tempo-operator" || true)
  [ -n "${TEMPO_CRBS}" ] && echo "${TEMPO_CRBS}" | xargs oc --context="${SPOKE_CTX}" delete clusterrolebinding --ignore-not-found

  # COO was installed by Guide 3 for Perses, not by MCOA. MCOA keeps its own
  # managed-cluster Prometheus component after the full COO subscription is removed.
  uninstall_coo "${SPOKE_CTX}"
}

cleanup_guide2() {
  info "=== Cleanup Guide 2 ==="

  # Remove cross-cluster from spoke
  oc --context="${SPOKE_CTX}" delete gateway istio-eastwestgateway -n istio-system --ignore-not-found
  oc --context="${SPOKE_CTX}" delete gateway istio-eastwestgateway-sidecar -n istio-system --ignore-not-found
  oc --context="${SPOKE_CTX}" delete secrets -n istio-system -l istio/multiCluster=true --ignore-not-found
  oc --context="${SPOKE_CTX}" delete secret kiali-multi-cluster-secret -n istio-system --ignore-not-found
  oc --context="${SPOKE_CTX}" adm policy remove-cluster-role-from-user cluster-reader -z istio-reader-service-account -n istio-system 2>/dev/null || true
  oc --context="${SPOKE_CTX}" delete serviceaccount istio-reader-service-account -n istio-system --ignore-not-found

  # Remove spoke-two CRs (must complete before operators are removed)
  oc --context="${SPOKE_TWO_CTX}" delete gateway istio-eastwestgateway-sidecar -n istio-system --ignore-not-found
  oc --context="${SPOKE_TWO_CTX}" adm policy remove-cluster-role-from-user cluster-reader -z istio-reader-service-account -n istio-system 2>/dev/null || true
  oc --context="${SPOKE_TWO_CTX}" delete namespace ambient-demo bookinfo --ignore-not-found
  oc --context="${SPOKE_TWO_CTX}" delete kiali kiali -n istio-system --ignore-not-found
  oc --context="${SPOKE_TWO_CTX}" wait kiali/kiali -n istio-system --for=delete --timeout=120s 2>/dev/null || true
  oc --context="${SPOKE_TWO_CTX}" delete ztunnel default --ignore-not-found
  oc --context="${SPOKE_TWO_CTX}" wait ztunnel/default --for=delete --timeout=120s 2>/dev/null || true
  oc --context="${SPOKE_TWO_CTX}" delete istio default --ignore-not-found
  oc --context="${SPOKE_TWO_CTX}" wait istio/default --for=delete --timeout=120s 2>/dev/null || true
  oc --context="${SPOKE_TWO_CTX}" delete istiocni default --ignore-not-found
  oc --context="${SPOKE_TWO_CTX}" wait istiocni/default --for=delete --timeout=120s 2>/dev/null || true
  oc --context="${SPOKE_TWO_CTX}" delete namespace ztunnel istio-system istio-cni --ignore-not-found

  # Remove spoke-two operators (all CRs above must be gone)
  oc --context="${SPOKE_TWO_CTX}" delete subscriptions.operators.coreos.com kiali-ossm openshift-service-mesh-operator -n openshift-operators --ignore-not-found
  for subscription_label in \
    operators.coreos.com/kiali-ossm.openshift-operators \
    operators.coreos.com/servicemeshoperator3.openshift-operators; do
    oc --context="${SPOKE_TWO_CTX}" delete installplan -n openshift-operators \
      -l "${subscription_label}" --ignore-not-found
  done

  local CSV
  CSV=$(oc --context="${SPOKE_TWO_CTX}" get csv -n openshift-operators -l operators.coreos.com/kiali-ossm.openshift-operators --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | head -1)
  [ -n "${CSV}" ] && oc --context="${SPOKE_TWO_CTX}" delete csv "${CSV}" -n openshift-operators --ignore-not-found
  CSV=$(oc --context="${SPOKE_TWO_CTX}" get csv -n openshift-operators -l operators.coreos.com/servicemeshoperator3.openshift-operators --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | head -1)
  [ -n "${CSV}" ] && oc --context="${SPOKE_TWO_CTX}" delete csv "${CSV}" -n openshift-operators --ignore-not-found

  for suffix in sailoperator.io istio.io kiali.io; do
    local CRDS
    CRDS=$(oc --context="${SPOKE_TWO_CTX}" get crd --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | grep "\.${suffix}$" || true)
    [ -n "${CRDS}" ] && echo "${CRDS}" | xargs oc --context="${SPOKE_TWO_CTX}" delete crd --ignore-not-found
  done
  oc --context="${SPOKE_TWO_CTX}" delete clusterrole servicemeshoperator3-metrics-reader --ignore-not-found

  # Revert spoke to single-cluster
  oc --context="${SPOKE_CTX}" patch istio default --type=json \
    -p '[{"op":"remove","path":"/spec/values/global/multiCluster"},{"op":"remove","path":"/spec/values/global/network"},{"op":"remove","path":"/spec/values/global/meshNetworks"},{"op":"remove","path":"/spec/values/pilot/env"}]' 2>/dev/null || true
  oc --context="${SPOKE_CTX}" patch ztunnel default --type=json \
    -p '[{"op":"remove","path":"/spec/values/ztunnel/multiCluster"},{"op":"remove","path":"/spec/values/ztunnel/network"}]' 2>/dev/null || true
  oc --context="${SPOKE_CTX}" label namespace istio-system topology.istio.io/network- istio-discovery- 2>/dev/null || true
  oc --context="${SPOKE_CTX}" patch kiali kiali -n istio-system --type=json \
    -p '[{"op":"remove","path":"/spec/kubernetes_config/cluster_name"}]' 2>/dev/null || true

  # Detach spoke-two from ACM
  oc --context="${HUB_CTX}" delete klusterletaddonconfig "${SPOKE_TWO_CLUSTER_NAME}" \
    -n "${SPOKE_TWO_CLUSTER_NAME}" --ignore-not-found
  # Tear down the Klusterlet agent on spoke-two before waiting for the hub
  # namespace, mirroring the same order used for the primary spoke.
  oc --context="${SPOKE_TWO_CTX}" delete klusterlet klusterlet \
    --ignore-not-found --wait=false 2>/dev/null || true
  until ! oc --context="${SPOKE_TWO_CTX}" get klusterlet klusterlet &>/dev/null 2>&1; do
    echo "Waiting for spoke-two Klusterlet removal..."
    sleep 10
  done
  oc --context="${SPOKE_TWO_CTX}" delete namespace \
    open-cluster-management-agent open-cluster-management-agent-addon \
    open-cluster-management-policies \
    --ignore-not-found --wait=false 2>/dev/null || true
  oc --context="${HUB_CTX}" delete managedcluster "${SPOKE_TWO_CLUSTER_NAME}" \
    --ignore-not-found --wait=false
  until ! oc --context="${HUB_CTX}" get managedcluster "${SPOKE_TWO_CLUSTER_NAME}" &>/dev/null 2>&1; do
    echo "Waiting for spoke-two ManagedCluster removal..."
    sleep 10
  done
  oc --context="${HUB_CTX}" delete namespace "${SPOKE_TWO_CLUSTER_NAME}" --ignore-not-found

  # Clean up spoke-two ACM residue (objects that linger after Klusterlet teardown)
  if oc --context="${SPOKE_TWO_CTX}" get crd appliedmanifestworks.work.open-cluster-management.io &>/dev/null; then
    local AMWS
    AMWS=$(oc --context="${SPOKE_TWO_CTX}" get appliedmanifestwork -o name 2>/dev/null || true)
    [ -n "${AMWS}" ] && echo "${AMWS}" | xargs oc --context="${SPOKE_TWO_CTX}" delete --ignore-not-found
  fi
  # Release orphaned ConfigurationPolicy finalizers before ACM CRDs are removed
  if oc --context="${SPOKE_TWO_CTX}" get crd configurationpolicies.policy.open-cluster-management.io \
      &>/dev/null 2>&1; then
    local ORPHANED
    ORPHANED=$(oc --context="${SPOKE_TWO_CTX}" get configurationpolicy \
      -n "${SPOKE_TWO_CLUSTER_NAME}" -o json 2>/dev/null | \
      jq -r --arg cluster "${SPOKE_TWO_CLUSTER_NAME}" '.items[] |
        select(.metadata.deletionTimestamp != null) |
        select(.metadata.labels["policy.open-cluster-management.io/cluster-name"] == $cluster) |
        select(any(.metadata.finalizers[]?;
          . == "policy.open-cluster-management.io/delete-related-objects")) |
        .metadata.name' 2>/dev/null || true)
    for policy in ${ORPHANED}; do
      info "Releasing orphaned ConfigurationPolicy finalizer on spoke-two: ${policy}"
      oc --context="${SPOKE_TWO_CTX}" patch configurationpolicy "${policy}" \
        -n "${SPOKE_TWO_CLUSTER_NAME}" \
        --type=merge -p '{"metadata":{"finalizers":[]}}' 2>/dev/null || true
    done
  fi
  local PROM_RULES
  PROM_RULES=$(oc --context="${SPOKE_TWO_CTX}" get prometheusrule \
    -n openshift-monitoring -o name 2>/dev/null | grep '/acm-rs-' || true)
  [ -n "${PROM_RULES}" ] && echo "${PROM_RULES}" | xargs oc --context="${SPOKE_TWO_CTX}" \
    -n openshift-monitoring delete --ignore-not-found
  local RBAC
  RBAC=$(oc --context="${SPOKE_TWO_CTX}" get clusterrole,clusterrolebinding -o name 2>/dev/null | \
    grep -E '/(ocm:|.*open-cluster-management|.*multicluster-observability|.*observability.*mco)' || true)
  [ -n "${RBAC}" ] && echo "${RBAC}" | xargs oc --context="${SPOKE_TWO_CTX}" delete --ignore-not-found
  local WEBHOOKS
  WEBHOOKS=$(oc --context="${SPOKE_TWO_CTX}" get \
    validatingwebhookconfiguration,mutatingwebhookconfiguration -o name 2>/dev/null | \
    grep -E '/.*(open-cluster-management|multicluster|observability)' || true)
  [ -n "${WEBHOOKS}" ] && echo "${WEBHOOKS}" | xargs oc --context="${SPOKE_TWO_CTX}" delete --ignore-not-found
  # APIServices: ACM/MCE + Observatorium; Hive only when no live workloads
  local APIS
  APIS=$(oc --context="${SPOKE_TWO_CTX}" get apiservice -o name 2>/dev/null | \
    grep -E '\.(open-cluster-management\.io|multicluster\.openshift\.io|multicluster\.x-k8s\.io|observatorium\.io)$' || true)
  [ -n "${APIS}" ] && echo "${APIS}" | xargs oc --context="${SPOKE_TWO_CTX}" delete --ignore-not-found
  if ! (oc --context="${SPOKE_TWO_CTX}" get namespace hive &>/dev/null && \
        [ -n "$(oc --context="${SPOKE_TWO_CTX}" get deploy,statefulset,daemonset,pod \
          -n hive -o name 2>/dev/null || true)" ]); then
    local HIVE_APIS
    HIVE_APIS=$(oc --context="${SPOKE_TWO_CTX}" get apiservice -o name 2>/dev/null | \
      grep -E '\.(hive\.openshift\.io|hiveinternal\.openshift\.io)$' || true)
    [ -n "${HIVE_APIS}" ] && echo "${HIVE_APIS}" | xargs oc --context="${SPOKE_TWO_CTX}" delete --ignore-not-found
  fi
  # CRDs last — the cleanup above still needs their APIs
  local ACM_SPOKE_TWO_CRDS
  ACM_SPOKE_TWO_CRDS=$(oc --context="${SPOKE_TWO_CTX}" get crd -o name 2>/dev/null | \
    grep -E '\.(open-cluster-management\.io|multicluster\.openshift\.io|multicluster\.x-k8s\.io|observatorium\.io)$' || true)
  [ -n "${ACM_SPOKE_TWO_CRDS}" ] && echo "${ACM_SPOKE_TWO_CRDS}" | xargs oc --context="${SPOKE_TWO_CTX}" delete --ignore-not-found
  if ! (oc --context="${SPOKE_TWO_CTX}" get namespace hive &>/dev/null && \
        [ -n "$(oc --context="${SPOKE_TWO_CTX}" get deploy,statefulset,daemonset,pod \
          -n hive -o name 2>/dev/null || true)" ]); then
    local HIVE_CRDS
    HIVE_CRDS=$(oc --context="${SPOKE_TWO_CTX}" get crd -o name 2>/dev/null | \
      grep -E '\.(hive\.openshift\.io|hiveinternal\.openshift\.io)$' || true)
    [ -n "${HIVE_CRDS}" ] && echo "${HIVE_CRDS}" | xargs oc --context="${SPOKE_TWO_CTX}" delete --ignore-not-found
  fi

  # Remove UWM config from spoke-two only if the tutorial created it
  disable_uwm "${SPOKE_TWO_CTX}"
}

cleanup_guide1() {
  info "=== Cleanup Guide 1 ==="
  local CRDS ACM_CRS ACM_CRBS CSV

  # Step 1 — Remove demo apps and mesh CRs from spoke
  oc --context="${SPOKE_CTX}" delete gateway waypoint -n ambient-demo --ignore-not-found
  oc --context="${SPOKE_CTX}" delete namespace ambient-demo bookinfo --ignore-not-found
  oc --context="${SPOKE_CTX}" delete ossmconsole ossmconsole -n istio-system --ignore-not-found
  oc --context="${SPOKE_CTX}" wait ossmconsole/ossmconsole -n istio-system --for=delete --timeout=120s 2>/dev/null || true
  oc --context="${SPOKE_CTX}" delete kiali kiali -n istio-system --ignore-not-found
  oc --context="${SPOKE_CTX}" wait kiali/kiali -n istio-system --for=delete --timeout=120s 2>/dev/null || true
  oc --context="${SPOKE_CTX}" delete secret acm-observability-certs cacerts -n istio-system --ignore-not-found
  oc --context="${SPOKE_CTX}" delete configmap kiali-cabundle -n istio-system --ignore-not-found
  oc --context="${SPOKE_CTX}" delete ztunnel default --ignore-not-found
  oc --context="${SPOKE_CTX}" wait ztunnel/default --for=delete --timeout=120s 2>/dev/null || true
  oc --context="${SPOKE_CTX}" delete istio default --ignore-not-found
  oc --context="${SPOKE_CTX}" wait istio/default --for=delete --timeout=120s 2>/dev/null || true
  oc --context="${SPOKE_CTX}" delete istiocni default --ignore-not-found
  oc --context="${SPOKE_CTX}" wait istiocni/default --for=delete --timeout=120s 2>/dev/null || true
  oc --context="${SPOKE_CTX}" delete namespace ztunnel istio-system istio-cni --ignore-not-found

  # Step 2 — Uninstall MCOA federation while ACM is still running
  local ns
  for ns in bookinfo ambient-demo ztunnel istio-system; do
    remove_mcoa_ref monitoring.coreos.com prometheusrules "kiali-istio-aggregation-${ns}" 2>/dev/null || true
  done
  for ns in bookinfo ambient-demo ztunnel istio-system; do
    remove_mcoa_ref monitoring.rhobs scrapeconfigs "kiali-istio-platform-federation-${ns}" 2>/dev/null || true
  done
  remove_mcoa_ref monitoring.rhobs scrapeconfigs kiali-istio-federation 2>/dev/null || true

  for ns in istio-system ztunnel ambient-demo bookinfo; do
    oc --context="${HUB_CTX}" delete prometheusrule "kiali-istio-aggregation-${ns}" \
      -n open-cluster-management-observability --ignore-not-found
    oc --context="${HUB_CTX}" delete scrapeconfig "kiali-istio-platform-federation-${ns}" \
      -n open-cluster-management-observability --ignore-not-found
  done
  oc --context="${HUB_CTX}" delete scrapeconfig kiali-istio-federation \
    -n open-cluster-management-observability --ignore-not-found

  # Step 3 — Remove ACM Observability from hub
  oc --context="${HUB_CTX}" delete mco observability --ignore-not-found
  oc --context="${HUB_CTX}" wait mco observability --for=delete --timeout=120s 2>/dev/null || true
  oc --context="${HUB_CTX}" delete deployment minio -n open-cluster-management-observability --ignore-not-found
  oc --context="${HUB_CTX}" delete service minio -n open-cluster-management-observability --ignore-not-found
  oc --context="${HUB_CTX}" delete secret thanos-object-storage -n open-cluster-management-observability --ignore-not-found
  oc --context="${HUB_CTX}" delete namespace open-cluster-management-observability --ignore-not-found

  # Step 4 — Detach spoke from ACM
  oc --context="${SPOKE_CTX}" delete klusterlet klusterlet --ignore-not-found --wait=false 2>/dev/null || true
  until ! oc --context="${SPOKE_CTX}" get klusterlet klusterlet &>/dev/null 2>&1; do
    echo "Waiting for Klusterlet removal..."
    sleep 10
  done
  oc --context="${SPOKE_CTX}" delete namespace \
    open-cluster-management-agent open-cluster-management-agent-addon \
    open-cluster-management-policies \
    --ignore-not-found --wait=false 2>/dev/null || true
  oc --context="${HUB_CTX}" delete managedcluster "${SPOKE_CLUSTER_NAME}" \
    --ignore-not-found --wait=false
  until ! oc --context="${HUB_CTX}" get managedcluster "${SPOKE_CLUSTER_NAME}" &>/dev/null 2>&1; do
    echo "Waiting for ManagedCluster removal..."
    sleep 10
  done
  oc --context="${HUB_CTX}" delete namespace "${SPOKE_CLUSTER_NAME}" --ignore-not-found

  # Step 5 — Clean up spoke ACM residue
  if oc --context="${SPOKE_CTX}" get crd appliedmanifestworks.work.open-cluster-management.io &>/dev/null; then
    local AMWS
    AMWS=$(oc --context="${SPOKE_CTX}" get appliedmanifestwork -o name 2>/dev/null || true)
    [ -n "${AMWS}" ] && echo "${AMWS}" | xargs oc --context="${SPOKE_CTX}" delete --ignore-not-found
  fi
  # Release ConfigurationPolicy finalizers on the spoke — the stranded policies
  # live on the spoke in the namespace named after the spoke cluster. The policy
  # controller may already be gone; scope to that namespace, the cluster-name
  # label, terminating state, and the specific "delete-related-objects" finalizer
  # to avoid touching unrelated policies.
  if oc --context="${SPOKE_CTX}" get crd configurationpolicies.policy.open-cluster-management.io \
      &>/dev/null 2>&1; then
    local ORPHANED policy
    ORPHANED=$(oc --context="${SPOKE_CTX}" get configurationpolicy \
      -n "${SPOKE_CLUSTER_NAME}" -o json 2>/dev/null | \
      jq -r --arg cluster "${SPOKE_CLUSTER_NAME}" '.items[] |
        select(.metadata.deletionTimestamp != null) |
        select(.metadata.labels["policy.open-cluster-management.io/cluster-name"] == $cluster) |
        select(any(.metadata.finalizers[]?;
          . == "policy.open-cluster-management.io/delete-related-objects")) |
        .metadata.name' 2>/dev/null || true)
    for policy in ${ORPHANED}; do
      info "Releasing orphaned ConfigurationPolicy finalizer on spoke: ${SPOKE_CLUSTER_NAME}/${policy}"
      oc --context="${SPOKE_CTX}" patch configurationpolicy "${policy}" \
        -n "${SPOKE_CLUSTER_NAME}" \
        --type=merge -p '{"metadata":{"finalizers":[]}}' 2>/dev/null || true
    done
  fi
  local PROM_RULES
  PROM_RULES=$(oc --context="${SPOKE_CTX}" get prometheusrule \
    -n openshift-monitoring -o name 2>/dev/null | grep '/acm-rs-' || true)
  [ -n "${PROM_RULES}" ] && echo "${PROM_RULES}" | xargs oc --context="${SPOKE_CTX}" \
    -n openshift-monitoring delete --ignore-not-found
  local RBAC
  RBAC=$(oc --context="${SPOKE_CTX}" get clusterrole,clusterrolebinding -o name 2>/dev/null | \
    grep -E '/(ocm:|.*open-cluster-management|.*multicluster-observability|.*observability.*mco)' || true)
  [ -n "${RBAC}" ] && echo "${RBAC}" | xargs oc --context="${SPOKE_CTX}" delete --ignore-not-found
  local WEBHOOKS
  WEBHOOKS=$(oc --context="${SPOKE_CTX}" get \
    validatingwebhookconfiguration,mutatingwebhookconfiguration -o name 2>/dev/null | \
    grep -E '/.*(open-cluster-management|multicluster|observability)' || true)
  [ -n "${WEBHOOKS}" ] && echo "${WEBHOOKS}" | xargs oc --context="${SPOKE_CTX}" delete --ignore-not-found
  # APIServices: ACM/MCE + Observatorium; Hive only when no live workloads
  local APIS
  APIS=$(oc --context="${SPOKE_CTX}" get apiservice -o name 2>/dev/null | \
    grep -E '\.(open-cluster-management\.io|multicluster\.openshift\.io|multicluster\.x-k8s\.io|observatorium\.io)$' || true)
  [ -n "${APIS}" ] && echo "${APIS}" | xargs oc --context="${SPOKE_CTX}" delete --ignore-not-found
  if ! (oc --context="${SPOKE_CTX}" get namespace hive &>/dev/null && \
        [ -n "$(oc --context="${SPOKE_CTX}" get deploy,statefulset,daemonset,pod \
          -n hive -o name 2>/dev/null || true)" ]); then
    local HIVE_APIS
    HIVE_APIS=$(oc --context="${SPOKE_CTX}" get apiservice -o name 2>/dev/null | \
      grep -E '\.(hive\.openshift\.io|hiveinternal\.openshift\.io)$' || true)
    [ -n "${HIVE_APIS}" ] && echo "${HIVE_APIS}" | xargs oc --context="${SPOKE_CTX}" delete --ignore-not-found
  fi
  # CRDs last — the cleanup above still needs their APIs
  local ACM_SPOKE_CRDS
  ACM_SPOKE_CRDS=$(oc --context="${SPOKE_CTX}" get crd -o name 2>/dev/null | \
    grep -E '\.(open-cluster-management\.io|multicluster\.openshift\.io|multicluster\.x-k8s\.io|observatorium\.io)$' || true)
  [ -n "${ACM_SPOKE_CRDS}" ] && echo "${ACM_SPOKE_CRDS}" | xargs oc --context="${SPOKE_CTX}" delete --ignore-not-found
  if ! (oc --context="${SPOKE_CTX}" get namespace hive &>/dev/null && \
        [ -n "$(oc --context="${SPOKE_CTX}" get deploy,statefulset,daemonset,pod \
          -n hive -o name 2>/dev/null || true)" ]); then
    local HIVE_CRDS
    HIVE_CRDS=$(oc --context="${SPOKE_CTX}" get crd -o name 2>/dev/null | \
      grep -E '\.(hive\.openshift\.io|hiveinternal\.openshift\.io)$' || true)
    [ -n "${HIVE_CRDS}" ] && echo "${HIVE_CRDS}" | xargs oc --context="${SPOKE_CTX}" delete --ignore-not-found
  fi

  # Step 6 — Remove ACM from hub
  oc --context="${HUB_CTX}" delete multiclusterhub multiclusterhub -n open-cluster-management --ignore-not-found
  info "Waiting for MultiClusterHub deletion (may take 5-15 minutes)..."
  oc --context="${HUB_CTX}" wait multiclusterhub multiclusterhub -n open-cluster-management --for=delete --timeout=900s 2>/dev/null || true
  oc --context="${HUB_CTX}" delete subscriptions.operators.coreos.com acm-operator-subscription -n open-cluster-management --ignore-not-found
  oc --context="${HUB_CTX}" delete csv -n open-cluster-management --all --ignore-not-found
  oc --context="${HUB_CTX}" delete namespace open-cluster-management --ignore-not-found --timeout=300s 2>/dev/null || true

  # Step 6b — Clean up hub-side ACM/MCE/Hive/Observatorium residue. These CRDs,
  # RBAC, webhooks, and APIService registrations can survive after the ACM
  # namespace and operators have been removed.
  local HUB_RBAC
  HUB_RBAC=$(oc --context="${HUB_CTX}" get clusterrole,clusterrolebinding -o name 2>/dev/null | \
    grep -E '/(ocm:|.*open-cluster-management|.*multiclusterengine|.*multicluster-observability|.*observability.*mco)' || true)
  [ -n "${HUB_RBAC}" ] && echo "${HUB_RBAC}" | xargs oc --context="${HUB_CTX}" delete --ignore-not-found
  local HUB_WEBHOOKS
  HUB_WEBHOOKS=$(oc --context="${HUB_CTX}" get \
    validatingwebhookconfiguration,mutatingwebhookconfiguration -o name 2>/dev/null | \
    grep -E '/.*(open-cluster-management|multicluster|observability)' || true)
  [ -n "${HUB_WEBHOOKS}" ] && echo "${HUB_WEBHOOKS}" | xargs oc --context="${HUB_CTX}" delete --ignore-not-found
  local HUB_APIS
  HUB_APIS=$(oc --context="${HUB_CTX}" get apiservice -o name 2>/dev/null | \
    grep -E '\.(open-cluster-management\.io|multicluster\.openshift\.io|multicluster\.x-k8s\.io|observatorium\.io)$' || true)
  [ -n "${HUB_APIS}" ] && echo "${HUB_APIS}" | xargs oc --context="${HUB_CTX}" delete --ignore-not-found
  if ! (oc --context="${HUB_CTX}" get namespace hive &>/dev/null && \
        [ -n "$(oc --context="${HUB_CTX}" get deploy,statefulset,daemonset,pod \
          -n hive -o name 2>/dev/null || true)" ]); then
    local HIVE_HUB_APIS
    HIVE_HUB_APIS=$(oc --context="${HUB_CTX}" get apiservice -o name 2>/dev/null | \
      grep -E '\.(hive\.openshift\.io|hiveinternal\.openshift\.io)$' || true)
    [ -n "${HIVE_HUB_APIS}" ] && echo "${HIVE_HUB_APIS}" | xargs oc --context="${HUB_CTX}" delete --ignore-not-found
  fi
  # CRDs last — the cleanup above still needs their APIs
  local HUB_CRDS
  HUB_CRDS=$(oc --context="${HUB_CTX}" get crd -o name 2>/dev/null | \
    grep -E '\.(open-cluster-management\.io|multicluster\.openshift\.io|multicluster\.x-k8s\.io|monitoring\.rhobs|observatorium\.io)$' || true)
  [ -n "${HUB_CRDS}" ] && echo "${HUB_CRDS}" | xargs oc --context="${HUB_CTX}" delete --ignore-not-found
  if ! (oc --context="${HUB_CTX}" get namespace hive &>/dev/null && \
        [ -n "$(oc --context="${HUB_CTX}" get deploy,statefulset,daemonset,pod \
          -n hive -o name 2>/dev/null || true)" ]); then
    local HIVE_HUB_CRDS
    HIVE_HUB_CRDS=$(oc --context="${HUB_CTX}" get crd -o name 2>/dev/null | \
      grep -E '\.(hive\.openshift\.io|hiveinternal\.openshift\.io)$' || true)
    [ -n "${HIVE_HUB_CRDS}" ] && echo "${HIVE_HUB_CRDS}" | xargs oc --context="${HUB_CTX}" delete --ignore-not-found
    # Remove the empty hive namespace that ACM installed Hive into
    if oc --context="${HUB_CTX}" get namespace hive &>/dev/null 2>&1; then
      oc --context="${HUB_CTX}" delete namespace hive --ignore-not-found --timeout=120s 2>/dev/null || true
    fi
  fi

  # Step 7 — Remove OSSM and Kiali operators from spoke
  oc --context="${SPOKE_CTX}" delete subscriptions.operators.coreos.com kiali-ossm openshift-service-mesh-operator -n openshift-operators --ignore-not-found
  for subscription_label in \
    operators.coreos.com/kiali-ossm.openshift-operators \
    operators.coreos.com/servicemeshoperator3.openshift-operators; do
    oc --context="${SPOKE_CTX}" delete installplan -n openshift-operators \
      -l "${subscription_label}" --ignore-not-found
  done
  CSV=$(oc --context="${SPOKE_CTX}" get csv -n openshift-operators -l operators.coreos.com/kiali-ossm.openshift-operators --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | head -1)
  [ -n "${CSV}" ] && oc --context="${SPOKE_CTX}" delete csv "${CSV}" -n openshift-operators --ignore-not-found
  CSV=$(oc --context="${SPOKE_CTX}" get csv -n openshift-operators -l operators.coreos.com/servicemeshoperator3.openshift-operators --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | head -1)
  [ -n "${CSV}" ] && oc --context="${SPOKE_CTX}" delete csv "${CSV}" -n openshift-operators --ignore-not-found
  for suffix in sailoperator.io istio.io kiali.io; do
    CRDS=$(oc --context="${SPOKE_CTX}" get crd --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null | grep "\.${suffix}$" || true)
    [ -n "${CRDS}" ] && echo "${CRDS}" | xargs oc --context="${SPOKE_CTX}" delete crd --ignore-not-found
  done
  oc --context="${SPOKE_CTX}" delete clusterrole servicemeshoperator3-metrics-reader --ignore-not-found

  # Step 8 — Remove UWM config only if the tutorial created it (label-guarded)
  # The hub ConfigMap is never created by this tutorial and is never removed.
  # Spoke-two is handled by cleanup_guide2.
  disable_uwm "${SPOKE_CTX}"

  # Final residue audit — report and fail on any leftover ACM/MCOA/Hive/
  # Observatorium/UWM artifacts so the script never silently declares success
  # while resources remain behind.
  local audit_failed=false
  for check_role in hub spoke; do
    local check_ctx="${HUB_CTX}"
    [ "${check_role}" = spoke ] && check_ctx="${SPOKE_CTX}"
    local residue
    residue=$(
      oc --context="${check_ctx}" get crd -o name 2>/dev/null | \
        grep -E '\.(open-cluster-management\.io|multicluster\.openshift\.io|multicluster\.x-k8s\.io|observatorium\.io|hive\.openshift\.io|hiveinternal\.openshift\.io)$' || true
      oc --context="${check_ctx}" get clusterrole,clusterrolebinding -o name 2>/dev/null | \
        grep -E '/(ocm:|.*open-cluster-management|.*multiclusterengine|.*multicluster-observability|.*observability.*mco)' || true
      oc --context="${check_ctx}" get \
        validatingwebhookconfiguration,mutatingwebhookconfiguration -o name 2>/dev/null | \
        grep -E '/.*(open-cluster-management|multicluster|observability)' || true
      oc --context="${check_ctx}" get apiservice -o name 2>/dev/null | \
        grep -E '\.(open-cluster-management\.io|multicluster\.openshift\.io|multicluster\.x-k8s\.io|observatorium\.io|hive\.openshift\.io|hiveinternal\.openshift\.io)$' || true
      for ns in open-cluster-management open-cluster-management-observability \
          open-cluster-management-agent open-cluster-management-agent-addon \
          open-cluster-management-policies hive; do
        oc --context="${check_ctx}" get namespace "${ns}" &>/dev/null 2>&1 && \
          echo "namespace/${ns}"
      done
    )
    # Check for tutorial-owned UWM ConfigMap on spoke only (hub CM never created here)
    if [ "${check_role}" = spoke ]; then
      local owned
      owned=$(oc --context="${check_ctx}" get configmap cluster-monitoring-config \
        -n openshift-monitoring \
        -o jsonpath='{.metadata.labels.kiali\.io/tutorial-owned}' 2>/dev/null || true)
      [ "${owned}" = "true" ] && \
        residue="${residue}${residue:+$'\n'}configmap/openshift-monitoring/cluster-monitoring-config"
    fi
    if [ -n "${residue}" ]; then
      audit_failed=true
      warn "Residual ${check_role} resources after cleanup:"
      echo "${residue}" | sed 's/^/  /' >&2
    fi
  done
  [ "${audit_failed}" = true ] && \
    error "Guide 1 cleanup left managed resources behind — inspect the output above"
  info "Residue audit passed: ACM, MCOA, Hive, Observatorium, and tutorial-owned UWM artifacts are absent"
}

# =============================================================================
# Main
# =============================================================================

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] <install|uninstall>

Automates the OSSM MultiCluster on OpenShift tutorial (Guides 1-4).

Options:
  --hub-context <ctx>         Hub cluster context (default: ossm-kiali-hub)
  --spoke-context <ctx>       Spoke cluster 1 context (default: ossm-kiali-spoke)
  --spoke-two-context <ctx>   Spoke cluster 2 context (default: ossm-kiali-spoke-two)
  --guides <list>             Comma-separated guide numbers to run (default: 1,2,3,4)
  --istio-version <ver>       Istio version to install (default: 1.30.1)
  -h, --help                  Show this help

Commands:
  install     Install selected guides sequentially
  uninstall   Remove selected guides (reverse order, ignoring failures)
EOF
  exit 0
}

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    --hub-context)       HUB_CTX="$2"; shift 2 ;;
    --spoke-context)     SPOKE_CTX="$2"; shift 2 ;;
    --spoke-two-context) SPOKE_TWO_CTX="$2"; shift 2 ;;
    --guides)            GUIDES="${2// /,}"; shift 2 ;;
    --istio-version)     ISTIO_VERSION="$2"; shift 2 ;;
    -h|--help)           usage ;;
    install|uninstall)   COMMAND="$1"; shift ;;
    *) error "Unknown option: $1" ;;
  esac
done

[ -z "${COMMAND:-}" ] && error "No command specified. Use 'install' or 'uninstall'."

case "${COMMAND}" in
  install)
    info "Starting OSSM MultiCluster Tutorial installation"
    info "Hub context:       ${HUB_CTX}"
    info "Spoke context:     ${SPOKE_CTX}"
    info "Spoke-two context: ${SPOKE_TWO_CTX}"
    info "Guides:            ${GUIDES}"

    # Prerequisites check
    for cmd in oc openssl istioctl jq curl; do
      command -v "${cmd}" &>/dev/null || error "Required command not found: ${cmd}"
    done

    oc --context="${HUB_CTX}" whoami --show-server || error "Cannot reach hub cluster"
    oc --context="${SPOKE_CTX}" whoami --show-server || error "Cannot reach spoke cluster"
    if run_guide 2; then
      oc --context="${SPOKE_TWO_CTX}" whoami --show-server || error "Cannot reach spoke-two cluster"
    fi

    mkdir -p "${TMP_DIR}"

    if run_guide 1; then
      guide1_phase1_acm_hub
      guide1_phase2_import_spoke
      guide1_phase3_ossm3_spoke
      guide1_phase4_kiali
      guide1_phase5_demo_apps
      guide1_phase6_verification
    fi

    if run_guide 2; then
      guide2_phase1_spoke_two_ca
      guide2_phase2_import_spoke_two
      guide2_phase3_ossm3_spoke_two
      guide2_phase4_update_spoke
      guide2_phase5_east_west_gateways
      guide2_phase6_endpoint_discovery
      guide2_phase7_kiali_multicluster
      guide2_phase8_demo_apps_spoke_two
      guide2_phase9_verification
    fi

    if run_guide 3; then
      guide3_phase1_perses
      guide3_phase2_tempo
      guide3_verification
    fi

    if run_guide 4; then
      guide4_phase2_health_metrics
      guide4_phase3_servicemonitor
      guide4_phase4_recording_rules
      guide4_phase6_acm_hub_alerts
      guide4_phase7_netobserv
      guide4_verification
    fi

    info "=========================================="
    info "OSSM MultiCluster Tutorial fully installed"
    info "=========================================="
    info "Kiali URL: $(oc --context="${SPOKE_CTX}" get route kiali -n istio-system -o jsonpath='https://{.spec.host}' 2>/dev/null || echo 'N/A')"
    info "OpenShift Console (spoke): $(oc --context="${SPOKE_CTX}" get route console -n openshift-console -o jsonpath='https://{.spec.host}' 2>/dev/null || echo 'N/A')"
    ;;

  uninstall)
    info "Starting OSSM MultiCluster Tutorial uninstallation (reverse order, ignoring failures)"
    info "Hub context:       ${HUB_CTX}"
    info "Spoke context:     ${SPOKE_CTX}"
    info "Spoke-two context: ${SPOKE_TWO_CTX}"
    info "Guides:            ${GUIDES}"

    set +e

    run_guide 4 && cleanup_guide4
    run_guide 3 && cleanup_guide3
    run_guide 2 && cleanup_guide2
    run_guide 1 && cleanup_guide1

    rm -rf "${TMP_DIR}"

    info "=========================================="
    info "OSSM MultiCluster Tutorial fully uninstalled"
    info "=========================================="
    ;;
esac
