import os
import urllib.request
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    hostname = os.environ.get("ALB_HOSTNAME")
    urls = [
        f"http://{hostname}/vote",
        f"http://{hostname}/result"
    ]
    for url in urls:
        try:
            response = urllib.request.urlopen(url, timeout=5)
            logger.info(f"{url} responded with status code: {response.getcode()}")
        except Exception as e:
            logger.error(f"Error accessing {url}: {e}")
