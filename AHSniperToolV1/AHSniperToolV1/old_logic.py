
from AHSniperToolV1 import views

@app.route('/order66')
def executeOrder66():
    cur = conORCL.cursor()
    package = open('static/sql/arbitrary_package.sql')
    package_sql = package.read()
    sql_commands = package_sql.split('/')

    for sql_command in sql_commands:
        if len(sql_command) > 3:
            print('Executing:',sql_command )
            cur.execute(sql_command)
    conORCL.commit()
    return render_template('index.html')