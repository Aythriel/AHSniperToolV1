#Calls stored procedure to create tables, assuming they are not already created.
def createTables(orclConnection, orclCursor):
    if orclConnection is null or not orclConnection.ping():
        raise ConnectionError("Can't execute function without active connection.")
    if orclCursor is null:
        orclCursor = orclConnection.cursor()
    orclCursor.callproc('TABLE_MANAGEMENT.CREATE_TABLES')

#Calls stored procedure to delete tables, whether they exist or not.
def deleteTables(orclConnection, orclCursor):
    if orclConnection is null or not orclConnection.ping():
        raise ConnectionError("Can't execute function without active connection.")
    if orclCursor is null:
        orclCursor = orclConnection.cursor()
    orclCursor.callproc('TABLE_MANAGEMENT.DELETE_TABLES')

#Calls stored procedure to reset the tables by deleting them and re-creating them.
def resetTables(orclConnection, orclCursor):
    if orclConnection is null or not orclConnection.ping():
        raise ConnectionError("Can't execute function without active connection.")
    if orclCursor is null:
        orclCursor = orclConnection.cursor()
    orclCursor.callproc('TABLE_MANAGEMENT.RESET_TABLES')