#
# SPDX-License-Identifier: Apache-2.0
#

# Applies patches/<project path>/*.patch to the LineageOS platform when
# build/envsetup.sh is sourced. Patches that are already there are skipped,
# so sourcing envsetup again (or after repo sync) is harmless. A patch that
# does not apply stops its project with a message and leaves it unchanged.
#
# This file is sourced: it must not exit or change shell options.

meizu_apply_patches() {
    local top=$1 dir=$2 failed=0 proj patch cid rel tree

    for proj in $(cd "$dir" && find . -name '*.patch' -printf '%h\n' | sed 's|^\./||' | sort -u); do
        tree=$top/$proj
        if [ "$(git -C "$tree" rev-parse --show-toplevel 2>/dev/null)" != "$(cd "$tree" 2>/dev/null && pwd -P)" ]; then
            echo "meizu: $proj is not a git project in this checkout, its patches are not applied" >&2
            failed=1
            continue
        fi
        if [ -d "$(git -C "$tree" rev-parse --git-path rebase-apply)" ]; then
            echo "meizu: $proj has an unfinished git am, run 'git -C $proj am --abort' first" >&2
            failed=1
            continue
        fi
        for patch in "$dir/$proj"/*.patch; do
            rel=${patch#"$top"/}
            cid=$(sed -n 's/^Change-Id: //p' "$patch" | head -n 1)
            if [ -n "$cid" ] && git -C "$tree" log -n 500 --format=%b HEAD | grep -qxF "Change-Id: $cid"; then
                continue
            fi
            if git -C "$tree" apply --check --reverse "$patch" 2>/dev/null; then
                continue
            fi
            if GIT_COMMITTER_NAME=nomorecoolnicknames \
               GIT_COMMITTER_EMAIL=nomorecoolnicknames@users.noreply.github.com \
               git -C "$tree" am -q --3way --committer-date-is-author-date "$patch" >/dev/null 2>&1; then
                echo "meizu: applied $rel"
            else
                git -C "$tree" am --abort >/dev/null 2>&1
                echo "meizu: $rel does not apply to $proj at $(git -C "$tree" rev-parse --short HEAD)." >&2
                echo "meizu: fix the conflict or reset the project with 'repo sync -d $proj', then source build/envsetup.sh again." >&2
                failed=1
                break
            fi
        done
    done
    return $failed
}

meizu_apply_patches "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd -P)" \
    "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/patches"
