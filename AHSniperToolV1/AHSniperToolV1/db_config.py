import cx_Oracle
import mysql.connector as connectorSQL
import requests 
import json
import sys 
user = "LearningPLSQL"
pw = "AClpp_9102"
dsn = "localhost:1521/xe"
clientID = 'ad8980d6ee4a4d96929d63114a15e6cb'
clientSecret = 'nKhl13SHEt0cc55V3trMEsl6IBZrtCAX'
tokenScope = "https://eu.battle.net/oauth/token"
ahScope = "https://eu.api.blizzard.com/wow/auction/data/silvermoon?"

verbotenItems = [82800,123865,123866,123867,123868,123869, 136851]

class OracleConn:
    class __OnlyOne:
        def __init__(self):
            self.conn = cx_Oracle.connect(user,pw,dsn)
        def __str__(self):
            return repr(self) + self.conn
    instance = None
    def __init__(self):
        if not OracleConn.instance:
            OracleConn.instance = OracleConn.__OnlyOne()
    def __getattr__(self, name):
        return getattr(self.instance.conn, name)

class UndermineConn:
    class __OnlyOne:
        def __init__(self):
            try:
                
                self.conn = \
                connectorSQL.connect(host='newswire.theunderminejournal.com',
                                 database='newsstand', user='', password='')
            except:
                print("Unexpected error:", sys.exc_info()[0])
        def __str__(self):
            return repr(self) + self.conn
    instance = None
    def __init__(self):
        if not UndermineConn.instance:
            UndermineConn.instance = UndermineConn.__OnlyOne()
    def __getattr__(self, name):
        return getattr(self.instance.conn, name)

#main function for adding data to the oracle db
#for auctions table it pulls from blizz
#for items table it pulls from underminejournal
#for price data on each auction it pulls from underminejournal

def initOracleDB():
    oracle = OracleConn()
    undermine = UndermineConn()

    orclCursor = oracle.cursor()

    #check for items table
    orclCursor.execute('SELECT * FROM Items')
    orclExistingItems = orclCursor.fetchmany(5)
    if (len(orclExistingItems) < 1 ) and undermine.is_connected() : 
        print('Table Items was found uninitiated. Fetching items from underminejournal...')
        cursorUndermine = undermine.cursor()
        #underquery="SELECT DISTINCT(I.id),I.name_enus, G.median FROM tblDBCItem I, tblItemGlobal G WHERE I.id=G.item AND REGION='EU'"
        underquery="SELECT I.id,I.name_enus, G.median FROM tblDBCItem I INNER JOIN tblItemGlobal G ON I.id=G.item AND REGION='US' GROUP BY I.id"
        cursorUndermine.execute(underquery)
        records = cursorUndermine.fetchall()
        print ('Total items fetched from underminejournal:  ', len(records))
            
        #inserting items into oracle 
        for record in records:
            itemID = record[0]
            itemName = record[1]
            itemValue = record[2]
            print("Inserting Item: {} - {}".format(itemID,itemName))
            orclCursor.callproc('table_dml.insert_item', [itemID, itemName, itemValue])
        print('Done inserting items.')
    orclCursor.execute('SELECT * FROM Auctions')
    orclExistingAuctions = orclCursor.fetchmany(5)
    if (len(orclExistingAuctions) < 1):
        print("Table Auctions was found empty. Fetching data from blizzard; this WILL take more than a few minutes.")
        #auctions table needs to be created. this is a long process.
        parameters = {'grant_type' : 'client_credentials',
                    'client_id' : clientID,
                    'client_secret' : clientSecret}
        resToken = requests.post(tokenScope,data=parameters)
        print(resToken.text)
        jsonResponse =json.loads(resToken.text)
        token = jsonResponse['access_token']
        print("Got access token:{}".format(token))
    
        print("Getting AH Dump location")

        parameters = {'locale' : 'en_GB',
                  'access_token' : token}
        url = ahScope + 'access_token=' + token + '&locale=en_GB'
        print('Attempting get on:{}'.format(url))
        res = requests.get(url)

        print("Getting json... this takes more than a few minutes.")
        jsonResponse = json.loads(res.text)
        dumpURL = jsonResponse["files"][0]["url"]
        dumpITSELF = requests.get(dumpURL).text    
        print("Got the huge ass json dump.")
        dumpOBJ = json.loads(dumpITSELF)    
        print("Got a usable object. Begining insertion.")    
        realm = "Silvermoon"
        insertedItems = 0
        for auction in dumpOBJ["auctions"] :
            itemId = auction["item"]
            if itemId in verbotenItems: #items that just don't belong lol.
                continue
            idAuction = auction["auc"]
            #seller = auction["owner"] # blizzard doesn't provide this anymore...
            buyout = auction["buyout"]
            currentBid = auction["bid"]
            timeLeft = auction["timeLeft"]
            
            print('Inserting auction: {}'.format(idAuction))
            
            orclCursor.callproc('table_dml.insert_auction', [idAuction, realm, buyout, currentBid, timeLeft, itemId])
            insertedItems += 1
        print("Procedure done. Inserted {} auctions. Starting flask server.".format(insertedItems))