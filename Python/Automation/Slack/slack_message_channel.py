#!/bin/python
# ===========================================================
# Created By: Richard Barrett
# Organization: Mirantis
# Department: CSO Support
# Purpose: Automated Channel Message
# Date: 03/17/2020
# ===========================================================

import selenium
import shutil
import xlsxwriter
import os
import unittest
import requests
import subprocess
import getpass
import platform
import logging
import time 
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait 
from datetime import date

decrypt = "gpg --output secrets_test.json --decrypt secrets.gpg" 

if os.path.exists("secrets.gpg"):
      returned_value = subprocess.call(decrypt, shell=True)
else:
        print("The file does not exist")
            
import json
with open('secrets_test.json','r') as f:
      config = json.load(f)

# Definitions
# find_elements_by_name
# find_elements_by_xpath
# find_elements_by_link_text
# find_elements_by_partial_link_text
# find_elements_by_tag_name
# find_elements_by_class_name
# find_elements_by_css_selector

# System Variables
today = date.today()
date = today.strftime("%m/%d/%Y")
node = platform.node()
system = platform.system()
username = getpass.getuser()
version = platform.version()
current_directory = os.getcwd()
channel_name = "#sto-helpdesk"

# URL Variables 

# Check for Version of Chrome

# Options 
#options = webdriver.ChromeOptions() 
#options.add_argument("download.default_directory=current_directory", "--headless")

# WebDriver Path for System
if platform.system() == ('Windows'):
    browser = webdriver.Chrome("C:\Program Files (x86)\Google\Chrome\chromedriver.exe")
elif platform.system() == ('Linux'):
    browser = webdriver.Chrome(executable_path='/home/rbarrett/Drivers/Google/Chrome/chromedriver_linux64/chromedriver')
elif platform.system() == ('Darwin'):
    browser = webdriver(executable_path='~/Drivers/Google/Chrome/chromedriver_mac64/chromedriver')
else:
    print("Are you sure you have the Selenium Webdriver installed in the correct path?")
      
# Parent URL
browser.get("https://miracloud.slack.com")

# Credentials NEEDS UNIT TEST
username = browser.find_element_by_id("login")
password = browser.find_element_by_id("password")
username.send_keys(config['slack']['username'])
password.send_keys(config['slack']['password'])

# UI Container Handle for Notifications Window that Pops Up. 

# Authentication submit.click()
# For XPATH = //*[@id='index_google_sign_in_with_google']
element = WebDriverWait(browser, 20).until(
        EC.element_to_be_clickable((By.XPATH, "//*[@id='index_google_sign_in_with_google']")))
element.click();
print("Logging into Mirantis Slack!")

# Navigate to #sto-helpdesk
# For XPATH = //div[@id='CB1CK1HT7']/a/span]
element = WebDriverWait(browser, 20).until(
        EC.element_to_be_clickable((By.XPATH, "//div[@id='CB1CK1HT7']/a/span]")))
element.click();
print("#sto-helpdesk has been selected...")

# Send Message to channel at certain timeframe
# Powershell Variable = $(Get-Date -Format "yyyy")
# Linux & Mac Variable = $(date +%F)
# XPATH = //*[@id='undefined']/p
element = WebDriverWait(browser, 20).until(
        EC.element_to_be_clickable((By.XPATH, "//*[@id='undefined']/p]")))
element.click();
channel_message = browser.find_element_by_id("undefined")
channel_message.send_keys(config['slack']['message'])

# NEED TO PUT AN IF FUNCION AND UNIT TEST FOR SESSION TIMEOUTS!!!
# Quit the Webbrowser
time.sleep(5)

# Delete the Encrypted File
if os.path.exists("secrets_test.json"):
  os.remove("secrets_test.json")
  print("The file was removed and everything is clean!")
else:
  print("The file does not exist")

print("The download was successfull!")
browser.quit()

# Format Downloaded File to District Specifications
