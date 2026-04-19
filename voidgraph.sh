#!/usr/bin/env bash

pkg="$1"

if [ -z "$pkg" ]; then
	echo "Usage: voidgraph <package>"
	exit 1
fi

mkdir -p "$HOME/Pictures/VoidPkgGraphs"

date_tag=$(date +"%Y-%m-%d_%H-%M-%S")

out="$HOME/Pictures/VoidPkgGraphs/${pkg}_${date_tag}.png"

(
	echo 'digraph G {'
	echo '  graph [bgcolor="#1e1e1e"];'
	echo '  node [style=filled, fontcolor="#fbf1c7"];'
	echo '  edge [color="#ffda33"];'

echo "\"$pkg\" [fillcolor=\"#ff5733\", shape=box];"

xbps-query -x "$pkg" | sed 's/>=.*//' | awk -v pkg="$pkg" '
{
	print "\"" $1 "\" [fillcolor=\"#3c3836\"];"
	print "\"" pkg "\" -> \"" $1 "\";"
}
'

echo '}'
) | dot -Tpng -Grankdir=LR -Gsplines=true > "$out"

echo "Graph saved to: $out"
