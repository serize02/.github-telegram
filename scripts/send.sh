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
    
    MESSAGE=$(
      echo -e "🚀 *Push Event* in \`$(escape_markdown "$REPO")\`\n"
      echo -e "👤 *Author:* \`$(escape_markdown "$AUTHOR")\`\n"
      echo -e "🌿 *Branch:* \`$(escape_markdown "$BRANCH")\`\n"
    )

    send_message "$MESSAGE"
    ;;

  pull_request)
    AUTHOR=$(jq -r '.pull_request.user.login' "$EVENT_PATH")
    TITLE=$(jq -r '.pull_request.title' "$EVENT_PATH")
    SOURCE_BRANCH=$(jq -r '.pull_request.head.ref' "$EVENT_PATH")
    TARGET_BRANCH=$(jq -r '.pull_request.base.ref' "$EVENT_PATH")

    MESSAGE=$(
      echo -e "🔀 *Pull request* in \`$(escape_markdown "$REPO")\`\n"
      echo -e "👤 *Author:* \`$(escape_markdown "$AUTHOR")\`\n"
      echo -e "📜 *Title:* \`$(escape_markdown "$TITLE")\`\n"
      echo -e "🌿 *Source:* \`$(escape_markdown "$SOURCE_BRANCH")\` → *Target:* \`$(escape_markdown "$TARGET_BRANCH")\`\n"
    )

    send_message "$MESSAGE"  
    ;;

  *)
    send_message "⚠️ Unknown event: $EVENT_NAME"
    ;;
esac