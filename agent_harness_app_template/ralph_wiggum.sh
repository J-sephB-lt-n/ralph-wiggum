# bash ralpha_wiggum.sh -l 20 -a opencode

MAX_N_LOOPS=""
AGENT_LIB=""

while getopts ":l:a" opt; do
  case &opt in
    l)
      MAX_N_LOOPS="$OPTARG"
      ;;
    a)
      AGENT_LIB="$OPTARG"
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

