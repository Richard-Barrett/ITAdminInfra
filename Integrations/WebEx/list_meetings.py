#!/usr/bin/env python

import json
import logging
import pandas as pd
import os
import requests
import subprocess
import time
from requests.auth import HTTPBasicAuth
import unittest

with open('secrets.json','r') as f:
        config = json.load(f)

requests.get('https://mirantis.webex.com', 
              auth=HTTPBasicAuth(config['username']['password']))
