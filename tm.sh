#!/usr/bin/env bash

# Connect to a remot server and start a tmux session

SERVER="myserver"

ssh -t "$SERVER" '
if tmux has-session -t main 2>/dev/null; then
	tmux attach -t main
else
	tmux new -s main
fi
'
