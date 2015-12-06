#!/bin/bash

# Simple calculator
function calc() {
        local result=""
        result="$(printf "scale=10;$*\n" | bc --mathlib | tr -d '\\\n')"
        #                       └─ default (when `--mathlib` is used) is 20
        #
        if [[ "$result" == *.* ]]; then
                # improve the output for decimal numbers
                printf "$result" |
                sed -e 's/^\./0./'        `# add "0" for cases like ".5"` \
                    -e 's/^-\./-0./'      `# add "0" for cases like "-.5"`\
                    -e 's/0*$//;s/\.$//'   # remove trailing zeros
        else
                printf "$result"
        fi
        printf "\n"
}

# Create a new directory and enter it
function mkd() {
        mkdir -p "$@" && cd "$@"
}

function targz ()
{
	local tmpFile="${@%/}.tar"
	cmd="gzip"

        tar -cvf "${tmpFile}"  "${@}" || return 1

	echo "Compressing .tar using \`${cmd}\`…"
        "${cmd}" -v "${tmpFile}" || return 1

        rm "${tmpFile}"

        echo "${tmpFile}.gz created successfully."
        exit 0
}

# Determine size of a file or total size of a directory
function fs() {
        if du -b /dev/null > /dev/null 2>&1; then
                local arg=-sbh
        else
                local arg=-sh
        fi
        if [[ -n "$@" ]]; then
                du $arg -- "$@"
        else
                du $arg .[^.]* *
        fi
}

# Use Git’s colored diff when available
hash git &>/dev/null
if [ $? -eq 0 ]; then
        function diff() {
                git diff --no-index --color-words "$@"
        }
fi

# Create a data URL from a file
function dataurl() {
        local mimeType=$(file -b --mime-type "$1")
        if [[ $mimeType == text/* ]]; then
                mimeType="${mimeType};charset=utf-8"
        fi
        echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# Create a git.io short URL
function gitio() {
        if [ -z "${1}" -o -z "${2}" ]; then
                echo "Usage: \`gitio slug url\`"
                return 1
        fi
        curl -i http://git.io/ -F "url=${2}" -F "code=${1}"
}

# Start a PHP server from a directory, optionally specifying the port
# (Requires PHP 5.4.0+.)
function phpserver() {
        local port="${1:-4000}"
        local ip=$(ipconfig getifaddr en1)
        sleep 1 && open "http://${ip}:${port}/" &
        php -S "${ip}:${port}"
}

# Compare original and gzipped file size
function gz() {
        local origsize=$(wc -c < "$1")
        local gzipsize=$(gzip -c "$1" | wc -c)
        local ratio=$(echo "$gzipsize * 100/ $origsize" | bc -l)
        printf "orig: %d bytes\n" "$origsize"
        printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio"
}

# All the dig info
function digga() {
        dig +nocmd "$1" any +multiline +noall +answer
}

# Escape UTF-8 characters into their 3-byte format
function escape() {
        printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
        # print a newline unless we’re piping the output to another program
        if [ -t 1 ]; then
                echo # newline
        fi
}

# Decode \x{ABCD}-style Unicode escape sequences
function unidecode() {
        perl -e "binmode(STDOUT, ':utf8'); print \"$@\""
        # print a newline unless we’re piping the output to another program
        if [ -t 1 ]; then
                echo # newline
        fi
}

# Get a character’s Unicode code point
function codepoint() {
        perl -e "use utf8; print sprintf('U+%04X', ord(\"$@\"))"
        # print a newline unless we’re piping the output to another program
        if [ -t 1 ]; then
                echo # newline
        fi
}

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
function getcertnames() {
        if [ -z "${1}" ]; then
                echo "ERROR: No domain specified."
                return 1
        fi

        local domain="${1}"
        echo "Testing ${domain}…"
        echo # newline

        local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
                | openssl s_client -connect "${domain}:443" 2>&1);

        if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
                local certText=$(echo "${tmp}" \
                        | openssl x509 -text -certopt "no_header, no_serial, no_version, \
                        no_signame, no_validity, no_issuer, no_pubkey, no_sigdump, no_aux");
                        echo "Common Name:"
                        echo # newline
                        echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//";
                        echo # newline
                        echo "Subject Alternative Name(s):"
                        echo # newline
                        echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
                                | sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2
                        return 0
        else
                echo "ERROR: Certificate not found.";
                return 1
        fi
}