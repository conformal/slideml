#!/bin/sh
#
# Copyright (c) 2011 Conformal Systems LLC <info@conformal.com>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# Prepares a release:
#   - Bumps version according to specified level (major, minor, or patch)
#   - Updates all necessary headers with new version
#   - Commits the changes
#   - Tags the release
#   - Creates a release tarball

PROJECT=slideml
PROJECT_UC=$(echo $PROJECT | tr '[:lower:]' '[:upper:]')
SCRIPT=$(basename $0)
VERFILE=version

# verify params
if [ $# -lt 1 ]; then
	echo "usage: $SCRIPT {major | minor | patch}"
	exit 1
fi

report_err()
{
	echo "$SCRIPT: error: $1" 1>&2
	exit 1
}


cd "$(dirname $0)"

# verify header exists
if [ ! -f "$VERFILE" ]; then
	report_err "$VERFILE does not exist"
fi

# verify valid release type
RTYPE="$1"
if [ "$RTYPE" != "major" -a "$RTYPE" != "minor" -a "$RTYPE" != "patch" ]; then
	report_err "release type must be major, minor, or patch"
fi

# verify git is available
if ! type git >/dev/null 2>&1; then
	report_err "unable to find 'git' in the system path"
fi

# verify the git repository is on the master branch
BRANCH=$(git branch | grep '\*' | cut -c3-)
if [ "$BRANCH" != "master" ]; then
	report_err "git repository must be on the master branch"
fi

# verify there are no uncommitted modifications prior to release modifications
NUM_MODIFIED=$(git diff 2>/dev/null | wc -l | sed 's/^[ \t]*//')
NUM_STAGED=$(git diff --cached 2>/dev/null | wc -l | sed 's/^[ \t]*//')
if [ "$NUM_MODIFIED" != "0" -o "$NUM_STAGED" != "0" ]; then
	report_err "the working directory contains uncommitted modifications"
fi

# get version
CUR_VER=$(cat "$VERFILE")
MAJOR=$(echo $CUR_VER | awk -v FS='.' '{print $1}')
MINOR=$(echo $CUR_VER | awk -v FS='.' '{print $2}')
PATCH=$(echo $CUR_VER | awk -v FS='.' '{print $3}')
if [ -z "$MAJOR" -o -z "$MINOR" -o -z "$PATCH" ]; then
	report_err "unable to get version from $VERFILE"
fi

# bump version according to level
if [ "$RTYPE" = "major" ]; then
	MAJOR=$(expr $MAJOR + 1)
	MINOR=0
	PATCH=0
elif [ "$RTYPE" = "minor" ]; then
	MINOR=$(expr $MINOR + 1)
	PATCH=0
elif [ "$RTYPE" = "patch" ]; then
	PATCH=$(expr $PATCH + 1)
fi
PROJ_VER="$MAJOR.$MINOR.$PATCH"

# update version file with new version
echo "$PROJ_VER" >"$VERFILE"

# commit and tag
TAG="${PROJECT_UC}_${MAJOR}_${MINOR}_${PATCH}"
git commit -am "Prepare for release ${PROJ_VER}." ||
    report_err "unable to commit changes"
git tag -a "$TAG" -m "Release ${PROJ_VER}" || report_err "unable to create tag"

# create temp working space and copy repo over
TD=$(mktemp -d /tmp/release.XXXXXXXXXX)
if [ ! -d "$TD" ]; then
	report_err "unable to create temp directory"
fi
RELEASE_DIR="$PROJECT-$PROJ_VER"
RELEASE_TAR="$PROJECT-$PROJ_VER.tgz"
git clone . "$TD/$RELEASE_DIR" ||
    report_err "unable to copy to $TD/$RELEASE_DIR"

# cleanup repository files
cd "$TD"
if [ -d "$RELEASE_DIR" -a -d "$RELEASE_DIR/.git" ]; then
        rm -rf "$RELEASE_DIR/.git"
fi
if [ -d "$RELEASE_DIR" -a -f "$RELEASE_DIR/.gitignore" ]; then
        rm -f "$RELEASE_DIR/.gitignore"
fi

# make snap
tar -zcf "$RELEASE_TAR" "$RELEASE_DIR" ||
    report_err "unable to create $RELEASE_TAR"


echo "Release tarball:"
echo "  $TD/$RELEASE_TAR"
echo ""
echo "If everything is accurate, use the following command to push the changes:"
echo "  git push --tags origin master"
