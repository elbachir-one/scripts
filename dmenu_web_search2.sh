#!/bin/sh

browser='chromium'
engine='https://duckduckgo.com/?q=%s'
bookmarks="$HOME/.bookmarks"

gotourl() {
	if [ "$nbrowser" = surf ]
	then
		xprop -id "$winid" -f _SURF_GO 8s -set _SURF_GO "$choice"
	elif [ -n "$winid" ] && [ -z "$nbrowser" ]
	then
		layout=$(setxkbmap -query | awk '/^layout:/{ print $2 }')
		setxkbmap -layout us
		xdotool key --clearmodifiers "$shortcut" \
			type --clearmodifiers --delay 2 "$choice"
		xdotool key --clearmodifiers Return
		setxkbmap -layout "$layout"
	elif [ -n "$nbrowser" ]
	then
		$nbrowser "$choice"
	else
		$browser "$choice"
	fi
}

searchweb() {
	choice=$(echo "$choice" | hexdump -v -e '/1 " %02x"')
	choice=$(echo "$engine" | sed "s/%s/${choice% 0a}/;s/[[:space:]]/%/g")
	gotourl
}

xprop -root | grep '^_NET_ACTIVE_WINDOW' && {
	winid=$(xprop -root _NET_ACTIVE_WINDOW | awk -F'[ ,]' '{print $NF}')
	class=$(xprop -id "$winid" WM_CLASS | awk -F'\"' '{ print $(NF - 1) }')
	case "$class" in
		Chromium) nbrowser='chromium' ;;
		*) winid="" ;;
	esac
}

tmpfile=$(mktemp /tmp/dmenu_websearch.XXXXXX)
trap 'rm "$tmpfile"' 0 1 15
printf '%s\n%s\n' "$uricur" "$1" > "$tmpfile"
cat "$bookmarks" >> "$tmpfile"
sed -i -E '/^(#|$)/d' "$tmpfile"
choice=$(dmenu -i -p "Go:" -w "$winid" < "$tmpfile") || exit 1

protocol='^(https?|ftps?|mailto|about|file):///?'
checkurl() {
	grep -Fx "$choice" "$tmpfile" &&
		choice=$(echo "$choice" | awk '{ print $1 }') && return 0
	[ ${#choice} -lt 4 ] && return 1
	echo "$choice" | grep -Z ' ' && return 1
	echo "$choice" | grep -EiZ "$protocol" && return 0
	echo "$choice" | grep -FZ '..' && return 1
	prepath=$(echo "$choice" | sed 's/(\/|#|\?).*//')
	echo "$prepath" |  grep -FvZ '.' && return 1
	echo "$prepath" |  grep -EZ '^([[:alnum:]~_:-]+\.?){1,3}' && return 0
}

if checkurl
then
	echo "$choice" | grep -EivZ "$protocol" &&
		choice="http://$choice"
	gotourl
else
	searchweb
fi
