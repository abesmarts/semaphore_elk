import requests
import time
import socket
import os
from datetime import datetime, timezone
import argparse
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException, WebDriverException

LOG_URL = "http://logstash:5000"
CHROMEDRIVER_PATH = "/root/Desktop/chromedriver"  # ChromeDriver must exist here


def try_login(url:str, username:str, password:str):
    opts = Options()
    opts.add_argument("--headless")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")

    # Use ChromeDriver from fixed path
    try:
        driver = webdriver.Chrome(executable_path=CHROMEDRIVER_PATH, options=opts)
    except WebDriverException as e:
        return {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "host": socket.gethostname(),
            "error": str(e),
            "website": "wellsfargo.com",
            "test_type": "bot-login",
            "metric_type": "web_automation",
            "Success": False,
            "log_type": "bot_data"
        }

    try:
        driver.get(url)
        driver.implicitly_wait(10)

        driver.find_element(By.ID, "j_username").send_keys(username)  # Add username
        driver.find_element(By.ID, "j_password").send_keys(password)  # Add password
        driver.find_element(By.ID, "signon-button").click()

        WebDriverWait(driver, 15).until(
            lambda d: (
                "dashboard" in d.page_source.lower()
                or "account" in d.page_source.lower()
                or "blocked" in d.page_source.lower()
                or "error" in d.page_source.lower()
            )
        )

        ok = "dashboard" in driver.page_source.lower()
    except TimeoutException:
        ok = False
    except Exception as e:
        ok = False
    finally:
        driver.quit()

    return {
        "host": socket.gethostname(),
        "website": "wellsfargo.com",
        "website_url": url,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "time": int(time.time()),
        "Success": ok,
        "test_type": "bot-login",
        "metric_type": "web_automation",
        "log_type": "bot_data"
    }


if __name__ == "__main__":
    MAX_ATTEMPTS = int(4)
    parser = argparse.ArgumentParser("Bot Website Login.")
   
    parser.add_argument("--url", required=True, help="URL for the bot to login to")
    parser.add_argument(
        "--username", required=True, help="Username you would like to use to login"
    )
    parser.add_argument(
        "--password", required=True, help="Password you would like to use to login"
    )
    parser.add_argument("--driver_path", default=None, help="Path to the chrome driver")


    args = parser.parse_args()

    # waiting a random amount of time to run the commands

       

    try:
        
        result = try_login(url=args.url, username=args.username, password=args.password)
        r = requests.post(LOG_URL, json=result, timeout=20)
        
        print(f"POST to {LOG_URL} → status {r.status_code}")
    except Exception as e:
        print(f"Error sending to Logstash: {e}")
