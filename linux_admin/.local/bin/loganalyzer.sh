#!/usr/bin/env bash
# loganalyzer.sh - Mini Project Option 2: Log File Analyzer
# Replace each TODO with real bash. Test each pipeline on the command
# line first, then paste it in. Use sample.log as your test data.

# NOTE:
# Without these, bash keeps going after an error and can write a report full
# of wrong numbers.
#   -e            stop as soon as any command fails
#   -u            stop on an unset variable, so a typo is an error instead of
#                 a silently empty string
#   -o pipefail   fail the pipeline if any stage fails, not just the last one
set -euo pipefail

# NOTE:
# Where to write the report, following the XDG Base Directory spec.
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/loganalyzer"
report="$state_dir/report.txt"

# Create it if missing, so a fresh machine needs no setup. -p also means
# "do not error if it already exists".
mkdir -p -- "$state_dir"


if [[ $# -ne 1 ]] ; then
    echo "usage: $0 <logfile>"
    exit 1
fi

file=$1

# NOTE:
# Three checks instead of one, so the message names the actual problem. A
# combined test could only say "something is wrong with this file".
if [[ ! -e "$file" ]]; then
	echo "Error: The file $file does not exist"
	exit 1
fi

if [[ ! -f "$file" ]]; then 
	echo "Error: The file $file is not a file"
	exit 1
fi

if [[ ! -r "$file" ]]; then 
	echo "Error: The file $file is not readable"
	exit 1
fi

# NOTE:
# "wc -l < file" instead of "wc -l file" so the filename is not echoed back.
total_lines=$(( $(wc -l < "$file") ))
# grep -c exits 1 when it finds nothing. Under "set -e" that kills the script
# on a clean log, which is exactly the case you least want to crash on.
# "|| true" swallows the exit status. The count still prints as 0.
errors=$(( $(grep -c 'ERROR' "$file" || true) ))
warnings=$(( $(grep -c 'WARNING' "$file" || true) ))

# NOTE:
# awk $NF is the last field on the line, which is the IP in this log format.
# The pipeline then does this:
#   sort      put identical IPs next to each other
#   uniq -c   collapse each group to one line, prefixed with its count
#   sort -rn  rank by that count, biggest first
#   head -5   keep the top 5
# uniq only spots duplicates that are already adjacent. That is why the first
# sort is not optional.
top_ips=$(
    awk '{ print $NF }' "$file" |
        sort |
        uniq -c |
        sort -rn |
        head -n 5
)


# BONUS:  strip the leading timestamp and bracketed PID with sed so identical
#         messages group together, and rank those too

top_messages=$(
    sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} //; s/\[[0-9]+\]//g' "$file" |
        sort |
        uniq -c |
        sort -rn |
        head -n 5
)

# NOTE:
# The braces group all this output into one stream. That way a single "| tee"
# at the end catches the whole report, instead of a redirect on every printf.
# tee -a appends and creates the file if missing. Plain tee would truncate it,
# leaving you with only the most recent run.
{
    printf 'Log Analysis Report\n'
    printf '===================\n'
    # date +%F is YYYY-MM-DD and %T is HH:MM:SS. Stamping each run is what makes
    # an appended file readable - otherwise the blocks are indistinguishable.
    printf 'Run at:   %s\n' "$(date '+%F %T %Z')"
    printf 'File:     %s\n\n' "$file"

    printf 'Total lines: %d\n' "$total_lines"
    printf 'Errors:      %d\n' "$errors"
    printf 'Warnings:    %d\n\n' "$warnings"

    printf 'Top 5 IP addresses:\n'
    printf '%s\n' "$top_ips"

    printf 'Top 5 messages:\n'
    printf '%s\n' "$top_messages"

    # Blank line + rule so consecutive appended runs stay readable.
    printf '\n-------------------------------------------\n\n'
} | tee -a "$report"

exit 0
