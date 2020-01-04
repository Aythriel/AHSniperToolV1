"""
Routes and views for the flask application.
"""
import sys


from AHSniperToolV1 import app
from AHSniperToolV1 import db_config # python local cu dictionarul global db_config 
from AHSniperToolV1 import table_management
from flask import Flask, render_template, redirect, url_for, request, session, make_response

import cx_Oracle #connector library for OracleDB and PLSQL
import mysql.connector as conektor #connector library for Underminejournal with MySQL 
import requests as httpreq
from datetime import datetime
from datetime import timedelta
import json

#useful for hashing and salts
import hashlib,binascii
from os import urandom

orclConnection = db_config.OracleConn()
print("Database version:", orclConnection.version)
undermineConnection = db_config.UndermineConn()


@app.route('/')
@app.route('/home')
def home():
    """Renders the home page."""
    if not 'loggedUser' in request.cookies:
        return redirect(url_for('doLogin'))
    return render_template(
        'home.html',
        title='Home Page',
        year=datetime.now().year,
    )

@app.route('/browse')
def browse():
    if not 'loggedUser' in request.cookies:
        return redirect(url_for('doLogin'))
    page = request.args.get('page')
    cursorOracle = orclConnection.cursor()
    cursorOracle.prepare("select I.NAME, A.buyout_value, A.current_bid, I.average_price, A.discount, A.realm, A.timeleft, A.id_auction, I.ID from (select t.*,row_number() over (order by ID_AUCTION) rownumber from AUCTIONS t) A, Items I where rownumber between :minrow and :maxrow and i.id=a.id_item")
    if page is None:
        minRow=0
        maxRow=100
    else:
        page = int(page)
        print('Page {} is {}'.format(page,type(page)))
        minRow=100*page
        maxRow=100*(page+1)
        print('MinRow: {}; MaxRow{}'.format(minRow,maxRow))
    results = cursorOracle.execute(None,{'minrow':minRow, 'maxrow':maxRow})

    return render_template(
        'browse.html',
        title='Browse',
        message='Browse to your heart''s content...',
        year=datetime.now().year,
        items = results
        )

@app.route('/account')
def account():
    print (request.cookies)
    if not 'loggedUser' in request.cookies:
        return redirect(url_for('doLogin'))
    user = request.cookies.get("loggedUser")
    userID = request.cookies.get("loggedUserID")
    orclCursor = orclConnection.cursor()
    
    itemQuery = "SELECT I.name, i.id FROM ITEMS I, WISHLISTS W WHERE i.id = w.id_item AND w.id_user = {}".format(userID)
    orclCursor.execute(itemQuery)
    itemResults = orclCursor.fetchall()

    auctionsQuery = "SELECT a.id_auction, i.name, a.discount, a.timeleft, ra.date_expires  FROM AUCTIONS A, RESERVED_AUCTIONS RA, ITEMS I WHERE a.id_auction=ra.id_auction AND a.id_item = I.id AND ra.id_user = {}".format(userID)
    orclCursor.execute(auctionsQuery)
    auctionResults = orclCursor.fetchall()

    accountQuery = "SELECT username, email, realm, funds FROM USERACCOUNTS WHERE ID={}".format(userID)
    orclCursor.execute(accountQuery)
    accountResults = orclCursor.fetchone()

    return render_template(
        'account.html',
 #       title="My Account",
 #       message="Welcome {}".format(user),
        year=datetime.now().year,
        items = itemResults,
        auctions = auctionResults,
        accInfo = accountResults
        )


@app.route('/contact')
def contact():
    if not 'loggedUser' in request.cookies:
        return redirect(url_for('doLogin'))
    """Renders the contact page."""
    return render_template(
        'contact.html',
        title='Contact',
        year=datetime.now().year,
        message='Your contact page.'
    )

@app.route('/about')
def about():
    """Renders the about page."""
    return render_template(
        'about.html',
        title='About',
        year=datetime.now().year,
        message='Your application description page.'
    )



@app.route('/login',methods=['POST','GET'])
def doLogin():
    if request.method == 'POST':
        name = request.form.get('username')
        pwBytes = bytes(request.form.get('password'),encoding="utf-8")
        oracleCursor = orclConnection.cursor()
        statement = "SELECT username,pw_hash, pw_salt, id FROM USERACCOUNTS WHERE USERNAME='{}'".format(name)
        print("Executing:{}".format(statement))
        oracleCursor.execute(statement)
        result = oracleCursor.fetchall()
        print(result)
        if(len(result) == 1): # s-a gasit un user cu acel nume
            fetched_pw_hash = result[0][1]
            fetched_pw_salt = result[0][2]
            print("Type of resulkt[0][2]: {}".format( type(result)))
            userID = str(result[0][3])
            pw_hash = hashlib.pbkdf2_hmac('sha256', pwBytes, fetched_pw_salt, 100000)
            
            print("Fetched pw_hash: {}".format(fetched_pw_hash))
            print("Calculated pw_hash: {}".format(pw_hash))
            if (fetched_pw_hash == pw_hash):
                response = make_response(render_template('home.html',title='Welcome {}'.format(name), message = 'Successfully logged in.'))
                response.set_cookie('loggedUser',name)
                response.set_cookie('loggedUserID',userID)
                return response
            else:
                response = make_response(render_template('login.html',message = 'Username/PW combination not found'))
                return response
        else:
            response = make_response(render_template('login.html', message = 'Username/PW combination not found'))
            return response

    elif request.method == 'GET':
        if 'loggedUser' in request.cookies:
            return redirect(url_for('home'))
        return render_template('login.html',title='Login page.',
                           message='Insert username and pw bo$$.'
                           )

@app.route('/createuser', methods=['POST'])
def createUser():
    print("----------------- CREATING USER -----------------------------")
    username = request.form['username']
    realm = request.form['realm']
    email = request.form['email']
    saltBytes = urandom(32)
    passwordBytes = bytes(request.form['password'],encoding="utf-8")
    print("salt bytes size:{}".format(len(saltBytes)))
    pw_hash = hashlib.pbkdf2_hmac('sha256', passwordBytes, saltBytes, 100000)
    pw_hashed = pw_hash.hex()
    
    print("pw_hash:{} length:{}".format(pw_hash,len(pw_hash)))
    print("salt length: {}".format(len(saltBytes)))
    oracleCursor = orclConnection.cursor()

    id = oracleCursor.var(int)
    oracleCursor.callproc('table_dml.insert_user',[username,email,realm,500,pw_hash,saltBytes,id])
    
    print('User creat si inserat cu success. Id={}'.format(id))
    return redirect('/login')

@app.route('/search', methods=['POST', 'GET'])
def searchAuctions():
    if request.method == "GET":
        return redirect('browse')
    itemName = request.form["itemName"]
    cursorOracle = orclConnection.cursor()
    statement = "SELECT I.NAME, A.buyout_value, A.current_bid, I.average_price, A.discount, A.realm, A.timeleft, A.id_auction, I.ID FROM AUCTIONS A, ITEMS I WHERE I.ID=A.ID_ITEM AND I.NAME='{}' ORDER BY A.discount DESC".format(itemName)
  
    print("Executing:{}".format(statement))
    results=cursorOracle.execute(statement).fetchall()
    return render_template(
        'browse.html',
        title='Search',
        message='Found the following auctions',
        year=datetime.now().year,
        items = results
        )



