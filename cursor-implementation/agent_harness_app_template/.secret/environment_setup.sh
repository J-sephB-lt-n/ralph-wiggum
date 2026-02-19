sudo apt update

declare -A install_cmds=(
	[curl]="sudo apt install curl"
	[tree]="sudo apt install tree"
	[cursoragent]="curl https://cursor.com/install -fsS | bash"
	[uv]="curl -LsSf https://astral.sh/uv/install.sh | sh"
)

install_order=(curl tree cursoragent uv)

for name in "${install_order[@]}"; do
	echo "installing $name"
	if eval "${install_cmds[$name]}"; then
		echo "successfully installed [$name]"
	else
		echo "FAILED to install [$name] - exit code $?"
	fi

	echo
done
