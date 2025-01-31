set -e

EVENT_NAME="${GITHUB_EVENT_NAME}"
REPO="${GITHUB_REPOSITORY}"
EVENT_PATH="${GITHUB_EVENT_PATH}"
TELEGRAM_URL="https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage"

send_message() {
  local MESSAGE="$1"
  curl -s -X POST "$TELEGRAM_URL" \
    -d "chat_id=${CHAT_ID}" \
    -d "parse_mode=MarkdownV2" \
    -d "text=${MESSAGE}"
}

escape_markdown() {
  echo "$1" | sed -E 's/([\_\*\[\]\(\)\~\`\>\#\+\-\=\|\{\}\.\!])/\\\1/g'
}

case "$EVENT_NAME" in
  push)
    AUTHOR=$(jq -r '.pusher.name' "$EVENT_PATH")
    BRANCH=${GITHUB_REF#refs/heads/}
    COMMIT_MESSAGES=$(jq -r '.commits[] | "- \(.message)"' "$EVENT_PATH" | sed 's/^/- /' | sed 's/^/- /' | sed 's/-/\\-/g' | paste -sd '\n')

    MESSAGE=$(
      echo "🚀 *Push Event* in \`$(escape_markdown "$REPO")\`"
      echo "👤 *Author:* \`$(escape_markdown "$AUTHOR")\`"
      echo "🌿 *Branch:* \`$(escape_markdown "$BRANCH")\`"
      echo "📜 *Commits:*"
      echo "$COMMIT_MESSAGES"
    )

    send_message "$MESSAGE"
    ;;

  pull_request)
    AUTHOR=$(jq -r '.pull_request.user.login' "$EVENT_PATH")
    TITLE=$(jq -r '.pull_request.title' "$EVENT_PATH")
    BODY=$(jq -r '.pull_request.body' "$EVENT_PATH")
    SOURCE_BRANCH=$(jq -r '.pull_request.head.ref' "$EVENT_PATH")
    TARGET_BRANCH=$(jq -r '.pull_request.base.ref' "$EVENT_PATH")

    MESSAGE=$(
      echo "🔀 *Pull Request* in \`$(escape_markdown "$REPO")\`"
      echo "👤 *Author:* \`$(escape_markdown "$AUTHOR")\`"
      echo "📜 *Title:* \`$(escape_markdown "$TITLE")\`"
      echo "📄 *Description:* \`$(escape_markdown "$BODY")\`"
      echo "🌿 *Source:* \`$(escape_markdown "$SOURCE_BRANCH")\` → *Target:* \`$(escape_markdown "$TARGET_BRANCH")\`"
    )

    send_message "$MESSAGE"
    ;;

  *)
    send_message "⚠️ Unknown event: $EVENT_NAME"
    ;;
esac