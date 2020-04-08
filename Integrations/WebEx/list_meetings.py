#!/usr/bin/env python

import getpass
import json
import logging
import pandas as pd
import platform
import os
import requests
import selenium
import subprocess
import lxml
import time
import unittest
from requests.auth import HTTPBasicAuth
from lxml import html
from selenium.webdriver import Chrome
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from datetime import date

decrypt = "gpg --output secrets.json --decrypt secrets.gpg" 

if os.path.exists("secrets.gpg"):
      returned_value = subprocess.call(decrypt, shell=True)
else:
        print("The file does not exist")
            
import json
with open('secrets.json','r') as f:
      config = json.load(f)

#requests.get('https://mirantis.webex.com', 
#              auth=HTTPBasicAuth(config['username']['password']))

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
delay = 20 # Seconds

# URL Variables 
url = "https://mirantis.webex.com"

# Element Pattern Variables
meetings_xpath_pattern = '//*[@id="main_content"]/div/div[1]/div[2]/div/div'

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
browser.get(url)

# Click on Sign-in 
# Sign-In Button XPATH = //*[@id='guest_signin_button']
element = WebDriverWait(browser, 20).until(
                        EC.element_to_be_clickable((By.XPATH, "//*[@id='guest_signin_button']")))
element.click();

fr = browser.findElementById("topframeset");
browser.switchTo().frame(fr);
#browser.switchTo.frame("topframeset")
#browser.switch_to.frame("main")

# Authentication
# Credentials NEEDS UNIT TEST
username = WebDriverWait(browser, delay).until(EC.presence_of_element_located((By.ID, 'mwx-ipt-username')))
#utente = browser.find_element_by_id("mwx-ipt-username").send_keys('user@gestione.eu')
password = WebDriverWait(browser, delay).until(EC.presence_of_element_located((By.ID, 'mwx-ipt-password')))
username.send_keys(config['user']['username'])
password.send_keys(config['user']['password'])

# Authentication submit.click()
# For XPATH = //*[@id='mwx-btn-logon']
element = WebDriverWait(browser, 20).until(
                EC.element_to_be_clickable((By.XPATH, "//*[@id='mwx-btn-logon']")))
element.click();
print("Logging into Mirantis WebEx System!")

# GET Page Source
# page = requests.get('https://mirantis.webex.com/webappng/sites/mirantis/meeting/home')
# tree = html.fromstring(page.content)

# GET Meetings
# meetings = tree.xpath('//*[@id="main_content"]/div[1]/div/div/div[2]/div/div')
#def find_meetings(driver, pattern):
#    meetings = driver.find_elements_by_xpath(pattern)
    #do something here
        
#try:
#    browser.get(url)
#    find_meetings(driver, meetings_xpath_pattern)

