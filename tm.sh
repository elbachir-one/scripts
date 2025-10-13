#!/usr/bin/env bash

# Connect to a remote server and start tmux or use an existing tmux session

SERVER="myserver" # "username@ip"

ssh -t "$SERVER" '
if tmux has-session -t main 2>/dev/null; then
	tmux attach -t main
else
	tmux new -s main
fi
'
