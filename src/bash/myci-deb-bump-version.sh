#!/bin/bash

# script for quick bumping up the minor version,
# i.e. version maj.min+1.0.

# Minor version from debian changelog will be incremented
# and a comment passed as argument is added.

# we want exit immediately if any command fails and we want error in piped commands to be preserved
set -eo pipefail

script_dir="$(dirname $0)/"

[[ ! -z ${DEBEMAIL+x} ]] || source ${script_dir}myci-error.sh "DEBEMAIL is unset"
[[ ! -z ${DEBFULLNAME+x} ]] || source ${script_dir}myci-error.sh "DEBFULLNAME is unset"

while [[ $# > 0 ]] ; do
	case $1 in
		--help)
			echo "Usage:"
			echo "  $(basename $0) [--patch|--major] <first-comment>"
			echo " "
			echo "By default minor version is bumped."
			echo "If --patch is supplied then patch version is bumped."
			echo "If --major is supplied then patch version is bumped."
			echo " "
			echo "Example:"
			echo "  $(basename $0) \"first comment item in new version changelog\""
			exit 0
			;;
		--patch)
			is_patch=true
			;;
		--major)
			is_major=true
			;;
		*)
            [ -z "$comment" ] || source ${script_dir}myci-error.sh "more than one comment specified"
			comment="$1"
			;;
	esac
	[[ $# > 0 ]] && shift;
done

[ ! -z "$comment" ] || source ${script_dir}myci-error.sh "comment as argument expected"

version=$(${script_dir}myci-deb-version.sh)

# echo $version

maj=$(echo $version | sed -n -e 's/^\([0-9]*\)\.[0-9]*\.[0-9]*$/\1/p')
min=$(echo $version | sed -n -e 's/^[0-9]*\.\([0-9]*\)\.[0-9]*$/\1/p')
rev=$(echo $version | sed -n -e 's/^[0-9]*\.[0-9]*\.\([0-9]*\)$/\1/p')

echo old version = $maj.$min.$rev

if [ "$is_major" == "true" ]; then
	echo bump major version
    newver=$((maj+1)).0.0
elif [ "$is_patch" == "true" ]; then
    echo bump patch version
    newver=$maj.$min.$((rev+1))
else
    echo bump minor version
    newver=$maj.$((min+1)).0
fi

echo new version = $newver

if [ -d build/debian ]; then
	deb_root_dir=build
elif [ -d debian ]; then
	deb_root_dir=.
fi

(cd $deb_root_dir; dch --newversion="$newver" "$comment" || source ${script_dir}myci-error.sh "updating debian/changelog failed")
