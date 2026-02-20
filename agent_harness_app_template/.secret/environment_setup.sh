sudo apt update

AGENT_LIB="$1"

if [ -z "$AGENT_LIB" ]; then
	echo "usage: bash environment_setup.sh [cursor|opencode]"
	exit 1
fi

declare -A install_cmds=(
	[curl]="sudo apt install curl"
	[tree]="sudo apt install tree"
	[cursoragent]="curl https://cursor.com/install -fsS | bash"
	[opencodeagent]="curl -fsSL https://opencode.ai/install | bash"
	[uv]='curl -LsSf https://astral.sh/uv/install.sh | sh'
)

install_order=(curl tree uv)

case "$AGENT_LIB" in
cursor)
	install_order+=(cursoragent)
	;;
opencode)
	install_order+=(opencodeagent)
	;;
*)
	echo "Invalid option: '$AGENT_LIB'"
	exit 1
	;;
esac

for name in "${install_order[@]}"; do
	echo "installing $name"
	if eval "${install_cmds[$name]}"; then
		echo "successfully installed [$name]"
	else
		echo "FAILED to install [$name] - exit code $?"
	fi

	echo
done
