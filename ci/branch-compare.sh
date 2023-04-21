#!/bin/bash
set -e
git config user.name $USERNAME
git config user.email $EMAIL
git config pull.rebase false
git fetch --all
git checkout -b $ORIGIN_BRANCH origin/$ORIGIN_BRANCH
git pull origin $ORIGIN_BRANCH
git checkout -b $MERGE_BRANCH origin/$MERGE_BRANCH
git pull origin $MERGE_BRANCH
git branch
git merge --no-commit --no-ff $ORIGIN_BRANCH  | tee automerge.out
git branch
if grep "Automatic merge failed" automerge.out; then
    echo "Merge conflict detected"
    # Generate a patch of the merge conflict
    patch=$(git diff --name-only --diff-filter=U)
    # Get the full patch contents
    patch_content=$(git diff -U0 $patch)
    echo $patch
    result=`echo "Merge conflict detected, Please review files : $patch"`
    echo $result
    echo "COMPARE_RESULT=$result" >> $GITHUB_OUTPUT
    git merge --abort
elif grep "Already up to date" automerge.out; then
    result=`echo "Nothing to merge, already up to date"`
    echo "COMPARE_RESULT=$result" >> $GITHUB_OUTPUT
else
    echo "No merge conflict, please merge main1 to stage1"
    result=`echo "No merge conflict, please merge main1 to stage1"`
    echo "COMPARE_RESULT=$result" >> $GITHUB_OUTPUT
    git merge --abort
fi
