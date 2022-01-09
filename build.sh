#!/bin/bash
set -eou pipefail
set +m

go build -buildmode=c-shared -o pam_line-otp.so

cp pam_line-otp.so /usr/lib64/security/.

U=tu-$(date +%s)
export P=$(uuidgen)

useradd $U
cmd="sqlite3 pam_line-otp.db 'INSERT INTO \"users\" VALUES (\"$U\", \"1111111\");'"
eval "$cmd"

passh -p env:P passwd $U >/dev/null

tail_journal() {
	set +x
	while read -r _l; do
		[[ "$_l" == "" ]] && continue
		while read -r l; do
			[[ "$l" == "" ]] && continue
			b="$(echo -e "$l" | wc -c)"
			[[ "$b" -lt 4 ]] && continue
			msg="$(ansi --yellow --bg-black --italic " $l")"
			b=
			msg="$(ansi --blue --underline "$(date +%H:%M:%S)") $(ansi --green --bold "$b") $(ansi --green --bold ">") $msg"
			echo -e "$msg"
		done < <(echo -e "$_l")
	done < <(./tail-journal.sh)
}
tail_journal &
BGPID1=$!
cleanup() {
	kill -9 $BGPID1 >/dev/null 2>&1||true
  sleep 1
  userdel --force -r $U
	echo OK
}
trap cleanup EXIT

{ passh -L .test-id-stdout -c 1 -p env:P -P "s password:" ssh -tt $U@localhost id; } >/dev/null 2>.test-id-stderr
