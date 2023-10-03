#!/bin/bash

# Get the previous promotion commit SHA
PREV_PROMOTION=$1

# Get the path to the app
PROD_PATH=$2

COMMITS=($(git rev-list ${PREV_PROMOTION}..HEAD \
    --grep "\[promotion\]" \
    --reverse \
    -- ${PROD_PATH}))

LAST_COMMIT=${COMMITS[${#COMMITS[@]} - 1]}

git reset --hard ${PREV_PROMOTION}
git cherry-pick ${COMMITS[@]} \
    --allow-empty \
    --strategy-option theirs \
    --rerere-autoupdate
git diff ${PREV_PROMOTION} \
    --output=promotion-diff.patch
echo -e "[promotion] fromCommit: ${LAST_COMMIT}\n\n---" > promotion-msg.txt
git log ${PREV_PROMOTION}..HEAD --format=%B--- >> promotion-msg.txt
git reset origin/HEAD --hard
