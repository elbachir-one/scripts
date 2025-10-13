#!/bin/bash -e

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-hv] [-d date] [FILE]...
Do stuff with FILE and write the result to standard output. With no FILE
or when FILE is -, read standard input.

    -h          display this help and exit
    -d date     date other than today's date
    -v          verbose mode. Can be used multiple times for increased
                verbosity.
EOF
}

# Initialize our own variables:
verbose=0
nomanipulation=0
date=$(date +%Y-%m-%d)
server_ip="192.168.1.15"
server_username="sh"
server_directory="/media/backup"

OPTIND=1 # Reset is necessary if getopts was used previously in the script.

while getopts "rnhvd:" opt; do
    case "$opt" in
        h)
            show_help
            exit 0
            ;;
        v)  verbose=$((verbose+1))
            ;;
        n)  nomaniuplation=$((nomaniuplation+1))
            ;;
        d)  date=$(date -d "$OPTARG" +%Y-%m-%d)
            ;;
        r)  date=$date-$(base64 /dev/urandom | tr -d '/+' | head -c 10) # remove /+ since that can choke URLs
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

tmp=$(mktemp -u)
mkdir -p "$tmp/$date"
trap 'rm -rf "$tmp"' EXIT

for src in "$@"
do

	if test -d "$src"
	then
		tar_name=$(basename "$src").tar
		tar cvf "$tar_name" "$src"
		src="$tar_name"
	fi

	if ! test -f "$src"
	then
		echo Missing filename "$src" >&2
		continue
	fi

	chmod +r "$src"

test $nomaniuplation || case $(file "$src") in
	*JPEG*)
		if hash cwebp
		then
			webptmp=$(mktemp --suffix=.webp)
			cwebp "$src" -o $webptmp
			echo "Squashing jpeg $(du -h "$src" "$webptmp")"
			src=${src%.*}.webp
			mv "$webptmp" "$src"
		fi
		;;
	*PNG*)
		hash pngquant && pngquant --ext .png -f "$src"
		;;
	*)
		echo Not compressing $src
		;;
esac

	dst=$(basename "$src")

	cp -v "$src" "$tmp/$date/$dst"

	# Create the directory on the remote server if it does not exist
	if ssh "$server_username@$server_ip" "mkdir -p $server_directory/$date" 2>/dev/null; then
		echo "Directory created successfully"
	else
		echo "Failed to create directory"
		exit 1
	fi

	if scp -v "$tmp/$date/$dst" "$server_username@$server_ip:$server_directory/$date/"
	then
		echo "https://$server_ip/$server_directory/$date/$dst"
		if hash pbcopy 2>/dev/null
		then
			echo -n "https://$server_ip/$server_directory/$date/$dst" | pbcopy
		else
			echo -n "https://$server_ip/$server_directory/$date/$dst" | xsel -b
		fi
	fi

done
