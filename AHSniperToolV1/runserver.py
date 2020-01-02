"""
This script runs the AHSniperToolV1 application using a development server.
"""

from os import environ
from AHSniperToolV1 import app, db_config, ajax_handlers
import threading

if __name__ == '__main__':
    startupTask = threading.Thread(target=db_config.initOracleDB())
    startupTask.start()

    HOST = environ.get('SERVER_HOST', 'localhost')
    try:
        PORT = int(environ.get('SERVER_PORT', '55831'))
    except ValueError:
        PORT = 5555
    app.run(HOST, PORT)
    