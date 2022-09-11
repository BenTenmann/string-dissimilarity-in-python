#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "$0")"
PIPELINE_SPEC="${1:-${SCRIPT_DIR}/../manifest/dist.yml}"
DATA_PATH="${2:-${SCRIPT_DIR}/../data/vdjdb.csv}"
OUTPUT_DIR="${3:-${SCRIPT_DIR}/../output}"

export DATA_PATH
export PIPELINE_SPEC

mkdir -p "${OUTPUT_DIR}"
for metric in Levenshtein CdrDist LongestCommonSubstring OptimalStringAlignment; do
  METRIC=$metric
  export METRIC
  yq -i e '.metric.name = env(METRIC)' "${PIPELINE_SPEC}"

  echo running $metric
  OUTPUT_PATH="${OUTPUT_DIR}"/"$(echo "${metric}" | tr '[:upper:]' '[:lower:]')".csv \
    python3 "${SCRIPT_DIR}"/compute_dist.py
done

FIGURE_DIR="${SCRIPT_DIR}"/../fig
WORKING_DIR="${SCRIPT_DIR}"/..
export FIGURE_DIR
export WORKING_DIR

Rscript "${SCRIPT_DIR}"/plot_results.R
