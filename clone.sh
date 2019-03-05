#!/usr/bin/env bash

URL="$1"; DIR="$2"; TAG="$3"
GIT="git -C ${DIR}"
echo "Obtaining '${URL}' in '${DIR}' ..."

is_head () {
    $GIT ls-remote -q --heads --exit-code "origin" "${TAG}"
    return $?
}

is_tag () {
    $GIT ls-remote -q --tags --exit-code "origin" "${TAG}"
    return $?
}

update () {
    if is_head; then
        echo "Found branch, using its commit"
        $GIT remote set-branches --add origin "${TAG}" || exit "$?"
        $GIT fetch origin "${TAG}" --depth=1 || exit "$?"
        SRC="origin/${TAG}"
    elif is_tag; then
        echo "Found tag, using its commit"
        $GIT fetch origin tag "${TAG}" --depth=1 || exit "$?"
        SRC="${TAG}"
    elif [ -z "${TAG}" ]; then
        echo "No tag provided, using origin HEAD commit"
        $GIT fetch origin "HEAD" --depth=1 || exit "$?"
        SRC="origin/HEAD"
    else
        echo "No such tag or branch, aborting!"
        exit 1
    fi
    $GIT checkout -f --detach "${SRC}" || exit "$?"
}

if [ ! -d "${DIR}" ]; then
    mkdir "${DIR}"
    $GIT clone "${URL}" . -n --depth=1 || exit "$?"
fi

update

echo "Done!"
