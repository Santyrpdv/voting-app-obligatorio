import urllib.request
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    base_url = os.environ.get("ALB_HOSTNAME")
    urls = [
        f"http://{base_url}/vote",
        f"http://{base_url}/result"
    ]
    for url in urls:
        try:
            response = urllib.request.urlopen(url, timeout=5)
            logger.info(f"{url} responded with status code: {response.getcode()}")
        except Exception as e:
            logger.error(f"Error accessing {url}: {e}")
