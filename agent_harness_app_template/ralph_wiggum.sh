# bash ralpha_wiggum.sh -l 20 -a opencode

MAX_N_LOOPS=""
AGENT_LIB=""

while getopts ":l:a:" opt; do
	case $opt in
	l)
		MAX_N_LOOPS="$OPTARG"
		;;
	a)
		AGENT_LIB="$OPTARG"
		;;
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
	echo 'ERROR: Argument -l (max n agent loops) is required.'
	exit 1
fi

if [[ -z "$AGENT_LIB" ]]; then
	echo 'ERROR: Argument -a (agent library) is required'
	exit 1
fi

case "$AGENT_LIB" in
cursor | opencode)
	echo "Using agent library [ $AGENT_LIB ]"
	;;
*)
	echo "Invalid option -a '$AGENT_LIB'. Valid options are ['cursor','opencode']"
	exit 1
	;;
esac

echo "MAX_N_LOOPS: $MAX_N_LOOPS"
echo "AGENT_LIB:   $AGENT_LIB"
