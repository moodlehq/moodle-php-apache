#!/usr/bin/env bash
set -euo pipefail

versions=(dev)
for dockerfile in versions/*/Dockerfile; do
    [[ -f "$dockerfile" ]] || continue
    version=${dockerfile#versions/}
    version=${version%/Dockerfile}
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+-[a-z0-9]+$ ]]; then
        echo "Invalid version directory: $version" >&2
        exit 1
    fi
    versions+=("$version")
done

jq -cn --args '[$ARGS.positional[] | {
    id: .,
    context: (if . == "dev" then "." else "versions/" + . end)
}]' "${versions[@]}" | jq -ce --arg requested "${1:-}" '
    if ([.[] | select(.id != "dev") | .id | split("-")[0]] | group_by(.) | any(length > 1)) then
        error("Multiple variants would publish the same PHP version tag")
    elif $requested == "" then .
    else
        ($requested | split(",") | map(gsub("^\\s+|\\s+$"; ""))) as $wanted |
        ([.[] | .id]) as $available |
        if ($wanted - $available | length) > 0 then
            error("Unknown versions: " + (($wanted - $available) | join(", ")))
        else
            [.[] | select(.id as $id | $wanted | index($id))]
        end
    end
'
