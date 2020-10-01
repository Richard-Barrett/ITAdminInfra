#!/usr/bin/env/python
from flask import Flask
import os


app = Flask(__name__)

@app.route('/hello_mcp_team', methods=['POST'])
def hello():
    return 'Hello MCP Team, Welcome to Slack!'

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
