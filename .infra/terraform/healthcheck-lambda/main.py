import os, json, urllib.request, urllib.error, boto3, logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

SNS_ARN   = os.environ["SNS_TOPIC_ARN"]
URLS      = [u.strip() for u in os.environ["URL_LIST"].split(",") if u.strip()]

sns = boto3.client("sns")

def notify(url, err_msg):
    subj = f"[ALERTA] {url} fuera de servicio"
    body = f"El chequeo de salud falló:\n\nURL: {url}\nError: {err_msg}"
    sns.publish(TopicArn=SNS_ARN, Subject=subj, Message=body)

def handler(event, context):
    for url in URLS:
        try:
            with urllib.request.urlopen(url, timeout=5) as resp:
                if resp.status != 200:
                    notify(url, f"Status {resp.status}")
        except Exception as e:
            notify(url, str(e))
    return {"checked": len(URLS)}
