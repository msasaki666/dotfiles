#!/usr/bin/env bash
# review-prs.sh — list PRs with user-review-requested:<USER> across multiple repos
# deps: gh, jq, column(optional), curl(optional for --all)
set -euo pipefail

USER="msasaki666"
FORMAT="table"             # table|tsv|md
EXTRA_QUERY=""             # e.g. "-is:draft"
ALL_PAGES="false"          # --all: fetch all pages via curl (needs GH_TOKEN)
INCLUDE_REVIEWING="false"  # --include-reviewing: also fetch reviewed-by:USER PRs
INCLUDE_MY_PR="false"      # --include-my-pr: also fetch author:USER PRs

usage() {
  cat <<'USAGE'
Usage:
  review-prs.sh [options] --repo OWNER/NAME [--repo OWNER/NAME]...

Options:
  --user USER               指名レビュー先（既定: msasaki666）
  --repo OWNER/NAME         対象repo（複数指定可, OR条件）※必須
  --extra "QUERY_PART"      追加フィルタ（例: "-is:draft"）
  --format table|tsv|md     出力形式（既定: table）
  --all                     100件超も取得（curl+GH_TOKEN必須）
  --include-reviewing       レビュー中PRも別セクションで表示
  --include-my-pr           自分が作成したPRも別セクションで表示
  -h, --help                このヘルプ

Examples:
  ./review-prs.sh --repo msasaki666/hoge --repo msasaki666/fuga
  ./review-prs.sh --repo msasaki666/some --extra "-is:draft"
  ./review-prs.sh --repo msasaki666/hoge --include-reviewing
  ./review-prs.sh --repo msasaki666/hoge --include-my-pr
  ./review-prs.sh --repo msasaki666/hoge --include-reviewing --include-my-pr
  FORMAT=md ./review-prs.sh --repo msasaki666/hoge --repo msasaki666/fuga
  export GH_TOKEN=ghp_xxx...; ./review-prs.sh --all --repo msasaki666/fuga
USAGE
}

REPOS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --user) USER="$2"; shift 2;;
    --repo) REPOS+=("$2"); shift 2;;
    --extra) EXTRA_QUERY="$2"; shift 2;;
    --format) FORMAT="$2"; shift 2;;
    --all) ALL_PAGES="true"; shift 1;;
    --include-reviewing) INCLUDE_REVIEWING="true"; shift 1;;
    --include-my-pr) INCLUDE_MY_PR="true"; shift 1;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1;;
  esac
done

if [[ ${#REPOS[@]} -eq 0 ]]; then
  echo "ERROR: --repo を1つ以上指定してください。" >&2
  usage
  exit 2
fi

REPO_QUERY="$(printf ' repo:%s' "${REPOS[@]}")"
API_BASE="https://api.github.com"

fetch_one_page_with_gh() {
  gh api --hostname github.com -H "Accept: application/vnd.github+json" "$1"
}

fetch_all_pages_with_curl() {
  : "${GH_TOKEN:?GH_TOKEN is required for --all}"
  local url="$1"
  local headers
  headers=$(mktemp); trap 'rm -f "$headers"' EXIT
  local all=""

  while :; do
    local resp
    resp=$(curl -fsSLD "$headers" -H "Accept: application/vnd.github+json" \
           -H "Authorization: Bearer ${GH_TOKEN}" "$url")
    all+=$'\n'"$resp"
    local next
    next=$(grep -i '^Link:' "$headers" | sed -n 's/.*<\([^>]*\)>; rel="next".*/\1/p' | head -n1 || true)
    [[ -n "$next" ]] || break
    url="$next"
  done

  printf '%s\n' "$all" | sed '/^$/d' | jq -s '{ total_count: (map(.total_count) | max // 0),
    items: ( map(.items // []) | add ) }'
}

# Fetch and display PRs for a given query condition
fetch_and_display_prs() {
  local query_condition="$1"
  local section_title="$2"

  local query="is:open is:pr ${query_condition} ${EXTRA_QUERY} ${REPO_QUERY}"
  local first_url
  first_url="${API_BASE}/search/issues?q=$(printf %s "$query" | jq -sRr @uri)&per_page=100"

  # Fetch JSON
  local json
  if [[ "$ALL_PAGES" == "true" ]]; then
    json=$(fetch_all_pages_with_curl "$first_url")
  else
    json=$(fetch_one_page_with_gh "$first_url")
  fi

  local count
  count=$(jq -r '.total_count' <<<"$json")

  if [[ "$count" -eq 0 ]]; then
    echo "${section_title}（@${USER} / repos: ${REPOS[*]}）: 該当なし"
    return
  fi

  local sorted
  sorted=$(jq '.items | sort_by(.updated_at) | reverse' <<<"$json")

  local tsv
  tsv=$(jq -r '
    .[]
    | [
        .title,
        (.repository_url | sub("https://api.github.com/repos/"; "")),
        .user.login,
        ((.updated_at | fromdateiso8601) + (9*60*60) | strftime("%Y-%m-%d %H:%M")),
        .html_url
      ]
    | @tsv
  ' <<<"$sorted")

  echo "${section_title}（@${USER} / repos: ${REPOS[*]}）: ${count}件"
  echo ""

  case "$FORMAT" in
    table)
      { printf '%s\t%s\t%s\t%s\t%s\n' "Title" "Repo" "Author" "Last Updated (JST)" "Link"
        printf '%s\n' "$tsv"
      } | column -t -s $'\t'
      ;;
    tsv)
      printf '%s\t%s\t%s\t%s\t%s\n' "Title" "Repo" "Author" "Last Updated (JST)" "Link"
      printf '%s\n' "$tsv"
      ;;
    md)
      echo '| Title | Repo | Author | Last Updated (JST) | Link |'
      echo '|---|---|---|---|---|'
      printf '%s\n' "$tsv" | awk -F'\t' '{printf("| %s | %s | %s | %s | %s |\n",$1,$2,$3,$4,$5)}'
      ;;
    *) echo "Unknown FORMAT=$FORMAT (use: table|tsv|md)" >&2; exit 1;;
  esac
}

# Main execution
# Always show review-requested PRs
fetch_and_display_prs "user-review-requested:${USER}" "レビュー待ちPR"

if [[ "$INCLUDE_REVIEWING" == "true" ]]; then
  echo ""
  echo "---"
  echo ""
  fetch_and_display_prs "reviewed-by:${USER} -author:${USER}" "レビュー中PR"
fi

if [[ "$INCLUDE_MY_PR" == "true" ]]; then
  echo ""
  echo "---"
  echo ""
  fetch_and_display_prs "author:${USER}" "レビュー依頼中または依頼待ちPR"
fi
