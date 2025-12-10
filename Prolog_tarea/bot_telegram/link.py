import requests

TOKEN = "8529128020:AAG-nyEAuDoRORMeWp9wwyx-5fOG-DhnFEM"
WEBHOOK_URL = "https://delemberv1999--geo-expert-bot-telegram-webhook.modal.run"

url = f"https://api.telegram.org/bot{TOKEN}/setWebhook?url={WEBHOOK_URL}"

response = requests.get(url)
print(response.json())