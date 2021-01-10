#!/usr/bin/env bash

# InfluxDB variables
influxdb_proto=${INFLUXDB_PROTO:-http}
influxdb_host=${INFLUXDB_HOST:-influxdb}
influxdb_port=${INFLUXDB_PORT:-8086}
influxdb_db=${INFLUXDB_DB:-speedtest}

influxdb_url="${influxdb_proto}://${influxdb_host}:${influxdb_port}"

# run speedtest & store result
json_result=$(speedtest -f json --accept-license --accept-gdpr)

# Extract data from speedtest result
result_id=$(echo "${json_result}" | jq -r '.result.id')
ping_latency=$(echo "${json_result}" | jq -r '.ping.latency')
download_bandwidth=$(echo "${json_result}" | jq -r '.download.bandwidth')
upload_bandwidth=$(echo "${json_result}" | jq -r '.upload.bandwidth')

# Ensure InfluxDB database exists
curl -d "q=CREATE DATABASE ${influxdb_db}" "${influxdb_url}/query"

# Write metric to InfluxDB
curl \
  -d "speedtest,result_id=${result_id} ping_latency=${ping_latency},download_bandwidth=${download_bandwidth},upload_bandwidth=${upload_bandwidth}" \
  "${influxdb_url}/write?db=${influxdb_db}"
