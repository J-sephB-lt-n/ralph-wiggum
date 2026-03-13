#!/usr/bin/env bash
# Four-phase agent loop: PLAN -> WRITE TESTS -> CODE -> REVIEW
#
# Usage:
#   bash ralph_wiggum.sh -l 20 -r 3 -a opencode
#
# Exit codes:
#   0 = all features COMPLETE
#   1 = max retries exceeded for a feature (early exit)
#   2 = max loops reached with work remaining

set -euo pipefail

AGENT_ROLES=("plan_agent" "test_writer_agent" "code_agent" "review_agent")

# ---------------------------------------------------------------------------
# CLI Argument parsing
# ---------------------------------------------------------------------------

MAX_N_LOOPS=""
MAX_RETRIES_PER_FEATURE=""
AGENT_LIB=""

while getopts ":l:r:a:" opt; do
	case $opt in
	l) MAX_N_LOOPS="$OPTARG" ;;
	r) MAX_RETRIES_PER_FEATURE="$OPTARG" ;;
	a) AGENT_LIB="$OPTARG" ;;
	:)
		echo "ERROR: -$OPTARG requires a value"
		exit 1
		;;
	\?)
		echo "ERROR: Invalid option -$OPTARG"
		exit 1
		;;
	esac
done

if [[ -z "$MAX_N_LOOPS" ]]; then
	echo 'ERROR: Argument -l (max loop iterations) is required.'
	exit 1
fi

if [[ -z "$MAX_RETRIES_PER_FEATURE" ]]; then
	echo 'ERROR: Argument -r (max retries per feature) is required.'
	exit 1
fi

if [[ -z "$AGENT_LIB" ]]; then
	echo 'ERROR: Argument -a (agent library) is required.'
	exit 1
fi

case "$AGENT_LIB" in
cursor | opencode)
	echo "Using agent library: $AGENT_LIB"
	;;
*)
	echo "ERROR: Invalid agent library '$AGENT_LIB'. Valid options: cursor, opencode"
	exit 1
	;;
esac

echo "MAX_N_LOOPS:            $MAX_N_LOOPS"
echo "MAX_RETRIES_PER_FEATURE: $MAX_RETRIES_PER_FEATURE"
echo "AGENT_LIB:              $AGENT_LIB"
echo ""

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

run_agent() {
	local iter_num="$1"
	local role="$2"
	local prompt_file=".secret/agent_prompts/${role}.md"
	local log_file="agent_logs/loop_${iter_num}_${role}.log"

	if [[ ! -f "$prompt_file" ]]; then
		echo "ERROR: Prompt file not found: $prompt_file"
		exit 1
	fi

	local prompt
	prompt=$(cat "$prompt_file")

	echo "  Running $role ..."
	if [[ "$AGENT_LIB" == "cursor" ]]; then
		cursor-agent --print --output-format stream-json --stream-partial-output --trust "$prompt" > "$log_file" 2>&1
	elif [[ "$AGENT_LIB" == "opencode" ]]; then
		opencode run "$prompt" > "$log_file" 2>&1
	fi
	echo "  $role finished."
}

all_features_complete() {
	local incomplete
	incomplete=$(jq '[.all_features[] | select(.status != "COMPLETE")] | length' features_list.json)
	[[ "$incomplete" -eq 0 ]]
}

max_retries_exceeded() {
	local exceeded
	exceeded=$(jq --argjson max "$MAX_RETRIES_PER_FEATURE" \
		'.all_features | any(.failed_review_count >= $max)' features_list.json)
	[[ "$exceeded" == "true" ]]
}

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------

for ((i = 1; i <= MAX_N_LOOPS; i++)); do
	echo "========================================="
	echo "LOOP ITERATION $i / $MAX_N_LOOPS"
	echo "========================================="

	if max_retries_exceeded; then
		echo "Max retries ($MAX_RETRIES_PER_FEATURE) exceeded for a feature. Early exit."
		exit 1
	fi

	if all_features_complete; then
		echo "All features are COMPLETE. Exiting successfully."
		exit 0
	fi

	for role in "${AGENT_ROLES[@]}"; do
		run_agent "$i" "$role"
	done

	echo ""
done

echo "Max loops ($MAX_N_LOOPS) reached with work still remaining."
exit 2
