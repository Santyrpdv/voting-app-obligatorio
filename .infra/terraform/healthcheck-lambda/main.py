import urllib.request
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    urls_string = os.getenv("URLS", "")
    urls = urls_string.split(",") if urls_string else []

    if not urls:
        logger.warning("No URLs provided in environment variable 'URLS'.")
        return

    for url in urls:
        try:
            response = urllib.request.urlopen(url, timeout=5)
            logger.info(f"{url} responded with status code: {response.getcode()}")
        except Exception as e:
            logger.error(f"Error accessing {url}: {e}")
