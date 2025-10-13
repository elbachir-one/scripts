#!/usr/bin/env bash

SERVER="myserver"

ssh -t "$SERVER" '
if tmux has-session -t main 2>/dev/null; then
	tmux attach -t main
else
	tmux new -s main \; run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh
fi
'
