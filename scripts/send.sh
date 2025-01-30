#!/bin/bash

# Exit on errors
set -e

# Get GitHub event type
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

# Function to escape MarkdownV2 special characters
escape_markdown() {
  echo "$1" | sed -E 's/([\_\*\[\]\(\)\~\`\>\#\+\-\=\|\{\}\.\!])/\\\1/g'
}

case "$EVENT_NAME" in
  push)
    AUTHOR=$(jq -r '.pusher.name' "$EVENT_PATH")
    BRANCH=${GITHUB_REF#refs/heads/}
    FILES=$(git diff-tree --no-commit-id --name-only -r "${GITHUB_SHA}" | sed 's/^/• /')

    MESSAGE=$(
      echo "🚀 *Push Event* in \`$(escape_markdown "$REPO")\`"
      echo "👤 *Author:* \`$(escape_markdown "$AUTHOR")\`"
      echo "🌿 *Branch:* \`$(escape_markdown "$BRANCH")\`"
      echo "📝 *Modified Files:*"
      echo "${FILES}"
    )

    send_message "$MESSAGE"
    ;;

  pull_request)
    AUTHOR=$(jq -r '.pull_request.user.login' "$EVENT_PATH")
    TITLE=$(jq -r '.pull_request.title' "$EVENT_PATH" | escape_markdown)
    BODY=$(jq -r '.pull_request.body' "$EVENT_PATH" | escape_markdown)
    SOURCE_BRANCH=$(jq -r '.pull_request.head.ref' "$EVENT_PATH")
    TARGET_BRANCH=$(jq -r '.pull_request.base.ref' "$EVENT_PATH")

    MESSAGE=$(
      echo "🔀 *Pull Request* in \`$(escape_markdown "$REPO")\`"
      echo "👤 *Author:* \`$(escape_markdown "$AUTHOR")\`"
      echo "📜 *Title:* ${TITLE}"
      echo "📄 *Description:* ${BODY}"
      echo "🌿 *Source:* \`$(escape_markdown "$SOURCE_BRANCH")\` → *Target:* \`$(escape_markdown "$TARGET_BRANCH")\`"
    )

    send_message "$MESSAGE"
    ;;

  issues)
    AUTHOR=$(jq -r '.issue.user.login' "$EVENT_PATH")
    TITLE=$(jq -r '.issue.title' "$EVENT_PATH" | escape_markdown)
    BODY=$(jq -r '.issue.body' "$EVENT_PATH" | escape_markdown)
    STATE=$(jq -r '.issue.state' "$EVENT_PATH")

    MESSAGE=$(
      echo "🐛 *Issue* in \`$(escape_markdown "$REPO")\`"
      echo "👤 *Author:* \`$(escape_markdown "$AUTHOR")\`"
      echo "📜 *Title:* ${TITLE}"
      echo "📄 *Description:* ${BODY}"
      echo "⚡ *Status:* \`$(escape_markdown "$STATE")\`"
    )

    send_message "$MESSAGE"
    ;;

  *)
    send_message "⚠️ Unknown event: $EVENT_NAME"
    ;;
esac