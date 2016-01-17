#! /bin/bash
# export our software to share with co-workers
# Only to be used by developers!
#
# Hormet Yiltiz, 2016
#

# this script should be put in ./lib/
cd -- "$(dirname "$BASH_SOURCE")"
cd ..


echo "Updating version file..."
git log | head -n 3 > VERSION

echo "Zipping latest software version..."
#git archive -9 -o "${PWD##*/}"-`git rev-parse --abbrev-ref HEAD`-`date "+%Y-%m-%d"`-`git log --pretty=format:"%h" -n 1`.zip HEAD

#FNAME="${PWD##*/}"-`git rev-parse --abbrev-ref HEAD`-`date "+%Y-%m-%d"`-`git log --pretty=format:"%h" -n 1`.zip #include branch name
FNAME="${PWD##*/}"-`date "+%Y-%m-%d"`-`git log --pretty=format:"%h" -n 1`.zip
git archive -9 -o $FNAME HEAD

echo ""
zip $FNAME VERSION
echo ""

echo "$FNAME generated!"
