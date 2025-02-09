# Getting Started

Follow these steps to set up the workflow in your GitHub repository:

## Create a Telegram Bot

1. Open Telegram and search for the user **@BotFather**.
2. Start a chat with BotFather and use the command `/newbot` to create a new bot.
3. Follow the prompts to name your bot and choose a username. Once created, you will receive a bot token.

## Obtain Your Chat ID

1. Start a chat with your new bot by searching for its username in Telegram.
2. Send any message to the bot.
3. To get your chat ID, you can use the following URL in your browser, replacing `YOUR_BOT_TOKEN` with your actual bot token:

https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates

4. Look for the `chat` object in the JSON response to find your `chat_id`.

## Add Secrets to Your GitHub Repository

1. Go to your GitHub repository where you want to set up the workflow.
2. Click on **Settings** > **Secrets and variables** > **Actions** > **New repository secret**.
3. Add the following secrets:
- **TOKEN**: Your Telegram bot token.
- **CHAT_ID**: Your chat ID.

## Configure the Workflow

1. Copy the content of this repo on `.github` directory.
2. Customize the YAML file as needed to specify which events you want to monitor.

## Commit and Push

1. Commit your changes and push them to your GitHub repository:
```bash
git add .
git commit -m "Add Telegram notification workflow"
git push
```
