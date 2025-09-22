#!/usr/bin/env bash
# review-prs.sh — list PRs with user-review-requested:<USER> across multiple repos
# deps: gh, jq, column(optional), curl(optional for --all)
set -euo pipefail

REVIEWER="msasaki666"
FORMAT="table"             # table|tsv|md
EXTRA_QUERY=""             # e.g. "-is:draft"
ALL_PAGES="false"          # --all: fetch all pages via curl (needs GH_TOKEN)

usage() {
  cat <<'USAGE'
Usage:
  review-prs.sh [options] --repo OWNER/NAME [--repo OWNER/NAME]...

Options:
  --reviewer USER           指名レビュー先（既定: msasaki666）
  --repo OWNER/NAME         対象repo（複数指定可, OR条件）※必須
  --extra "QUERY_PART"      追加フィルタ（例: "-is:draft"）
  --format table|tsv|md     出力形式（既定: table）
  --all                     100件超も取得（curl+GH_TOKEN必須）
  -h, --help                このヘルプ

Examples:
  ./review-prs.sh --repo msasaki666/hoge --repo msasaki666/fuga
  ./review-prs.sh --repo msasaki666/some --extra "-is:draft"
  FORMAT=md ./review-prs.sh --repo msasaki666/hoge --repo msasaki666/fuga
  export GH_TOKEN=ghp_xxx...; ./review-prs.sh --all --repo msasaki666/fuga
USAGE
}

REPOS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --reviewer) REVIEWER="$2"; shift 2;;
    --repo) REPOS+=("$2"); shift 2;;
    --extra) EXTRA_QUERY="$2"; shift 2;;
    --format) FORMAT="$2"; shift 2;;
    --all) ALL_PAGES="true"; shift 1;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1;;
  esac
done

if [[ ${#REPOS[@]} -eq 0 ]]; then
  echo "ERROR: --repo を1つ以上指定してください。" >&2
  usage
  exit 2
fi

# Build query
REPO_QUERY="$(printf ' repo:%s' "${REPOS[@]}")"
QUERY="is:open is:pr user-review-requested:${REVIEWER} ${EXTRA_QUERY} ${REPO_QUERY}"

API_BASE="https://api.github.com"
FIRST_URL="${API_BASE}/search/issues?q=$(printf %s "$QUERY" | jq -sRr @uri)&per_page=100"

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

# Fetch JSON
if [[ "$ALL_PAGES" == "true" ]]; then
  JSON=$(fetch_all_pages_with_curl "$FIRST_URL")
else
  RAW=$(fetch_one_page_with_gh "$FIRST_URL")
  JSON="$RAW" # single page
fi

COUNT=$(jq -r '.total_count' <<<"$JSON")

if [[ "$COUNT" -eq 0 ]]; then
  echo "レビュー待ちPR（@${REVIEWER} / repos: ${REPOS[*]}）: 該当なし"
  exit 0
fi

SORTED=$(jq '.items | sort_by(.updated_at) | reverse' <<<"$JSON")

TSV=$(jq -r '
  .[]
  | [
      .title,
      (.repository_url | sub("https://api.github.com/repos/"; "")),
      .user.login,
      ((.updated_at | fromdateiso8601) + (9*60*60) | strftime("%Y-%m-%d %H:%M")),
      .html_url
    ]
  | @tsv
' <<<"$SORTED")

case "$FORMAT" in
  table)
    { printf '%s\t%s\t%s\t%s\t%s\n' "Title" "Repo" "Author" "Last Updated (JST)" "Link"
      printf '%s\n' "$TSV"
    } | column -t -s $'\t'
    ;;
  tsv)
    printf '%s\t%s\t%s\t%s\t%s\n' "Title" "Repo" "Author" "Last Updated (JST)" "Link"
    printf '%s\n' "$TSV"
    ;;
  md)
    echo '| Title | Repo | Author | Last Updated (JST) | Link |'
    echo '|---|---|---|---|---|'
    printf '%s\n' "$TSV" | awk -F'\t' '{printf("| %s | %s | %s | %s | %s |\n",$1,$2,$3,$4,$5)}'
    ;;
  *) echo "Unknown FORMAT=$FORMAT (use: table|tsv|md)" >&2; exit 1;;
esac
