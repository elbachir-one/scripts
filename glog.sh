#!/usr/bin/env bash

gcop () {
	git log \
		--reverse \
		--color=always \
		--format="%C(cyan)%h %C(blue)%ar%C(auto)%d \
		%C(yellow)%s%+b %C(black)%ae" "$@" |
		fzf -i -e +s \
		--reverse \
		--tiebreak=index \
		--no-multi \
		--ansi \
		--preview="echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'" \
		--header "enter: view, C-c: copy hash" \
		--bind "enter:execute:$_viewGitLogLine | less -R" \
		--bind "ctrl-c:execute:$_gitLogLineToHash |
		xclip -r -sselection clipboard"
}
