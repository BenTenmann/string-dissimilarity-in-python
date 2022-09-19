#!/bin/bash

# ----- PREAMBLE ----------------------------------------------------------------------------------------------------- #
set -e

SCRIPT_DIR="$(dirname "$0")"
APP_HOME="${APP_HOME:-${SCRIPT_DIR}/..}"
source "${SCRIPT_DIR}"/util.sh

application_delimiter
display_center "${APP_HOME}"/assets/header.txt
echo application arguments: "${@:-defaults}"
echo application home: "$APP_HOME"
application_delimiter

PIPELINE_SPEC="${1:-${APP_HOME}/manifest/dist.yml}"
DATA_PATH="${2:-${APP_HOME}/data/vdjdb.csv}"
OUTPUT_DIR="${3:-${APP_HOME}/output}"

check_if_dependencies_are_present python3 Rscript yq
PREFIX=${APP_HOME} create_required_directories output fig logs

LOG_FILE="${APP_HOME}"/logs/"$(date '+%Y-%m-%d-%X'.log)"
touch "${LOG_FILE}"

export DATA_PATH
export PIPELINE_SPEC

# ----- SCRIPT ------------------------------------------------------------------------------------------------------- #
echo Running computations 🚀
application_delimiter
for metric in Levenshtein CdrDist LongestCommonSubstring OptimalStringAlignment; do
  METRIC=$metric
  export METRIC
  yq -i e '.metric.name = env(METRIC)' "${PIPELINE_SPEC}"

  echo computing $metric...
  OUTPUT_PATH="${OUTPUT_DIR}"/"$(echo "${metric}" | tr '[:upper:]' '[:lower:]')".csv \
    python3 "${SCRIPT_DIR}"/compute_dist.py &>> "${LOG_FILE}"
done

export OUTPUT_DIR
DATA_DIR=$OUTPUT_DIR python3 "${SCRIPT_DIR}"/metric_differences.py &>> "${LOG_FILE}"

FIGURE_DIR="${4:-${APP_HOME}/fig}"
WORKING_DIR="${5:-${APP_HOME}}"
export FIGURE_DIR
export WORKING_DIR

application_delimiter
echo Plotting figures 🖌
application_delimiter
Rscript "${SCRIPT_DIR}"/plot_results.R &>> "${LOG_FILE}"

echo Done! 🌟
