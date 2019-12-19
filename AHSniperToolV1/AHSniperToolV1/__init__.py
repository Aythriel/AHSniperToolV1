"""
The flask application package.
"""

from flask import Flask
app = Flask(__name__)
app.config['AHST_CLIENT_KEY'] = 'ad8980d6ee4a4d96929d63114a15e6cb'
app.config['AHST_CLIENT_SECRET'] = 'nKhl13SHEt0cc55V3trMEsl6IBZrtCAX'

import AHSniperToolV1.views
