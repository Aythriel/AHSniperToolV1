import sys
from AHSniperToolV1 import app
from AHSniperToolV1 import db_config # python local cu dictionarul global db_config 
from AHSniperToolV1 import table_management
from flask import Flask, render_template, redirect, url_for, request, session, make_response
from cx_Oracle import FIXED_CHAR, Date
from datetime import datetime
from datetime import timedelta


#for password hashing
import hashlib,binascii
from os import urandom

#for emails
import smtplib, ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from getpass import getpass


orclConnection = db_config.OracleConn()
undermineConnection = db_config.UndermineConn()

@app.route('/addToWishList', methods=['POST'])
def addToWishList():
    itemID = request.headers.get('Itemid');
    user = request.cookies.get("loggedUser",None)
    print("User {} wants to add item {} to his wishlist.".format(user,itemID))
    
    orclCursor = orclConnection.cursor()
    assignedID = orclCursor.var(int)
    try:
        orclCursor.callproc('table_dml.insert_wishlist',[user,itemID,assignedID])
        if assignedID.getvalue() is None:
            print("Itemul {} exista deja in wishlistul lui {}.".format(itemID,user))
            return "The item {} already exists in your wishlist.".format(itemID)
        else:
            print("Inserted wishlist entry with id={}".format(assignedID.getvalue()))
            return "Inserted wishlist entry with id={}".format(assignedID.getvalue())
    except:
        e = sys.exc_info()[0]
        print("Database Error: {}".format(e.args))
        return "Exception occured:{}".format(e)
    return "Successfully created wishlist entry with id {}.".format(assignedID.getvalue())

@app.route('/addToReserved', methods=['POST'])
def addToReserved():
    auID = request.headers.get('AucID');
    user = request.cookies.get("loggedUser",None)
    print("User {} wants to add item {} to his wishlist.".format(user,auID))
    if user == None:
        return "Error. No user logged in."
    orclCursor = orclConnection.cursor()
    assignedID = orclCursor.var(int)
    currentDate = Date.today()
    expiryDate = Date.today() + timedelta(days=2)
    
    try:
        orclCursor.callproc('table_dml.insert_reserved_auction',[user,auID,currentDate,expiryDate,assignedID])
        if assignedID.getvalue() is None:
            print("Itemul {} exista deja in wishlistul lui {}.".format(auID,user))
            return "The auction {} is already reserved.".format(auID)
        else:
            print("Inserted reservation for {}, entry with id={}".format(auID,assignedID.getvalue()))
            return "Reserved the auction {} with entry {}.".format(auID,assignedID.getvalue())
    except:
        e = sys.exc_info()[0]
        error, = e.args
        print("Database Error: {}".format(error))
        return "Exception occured:{}".format(error)
    return "Eroare b0$$."


@app.route('/removeFromWishList', methods=['DELETE'])
def removeFromWishList():
    itemID = request.headers.get('Itemid');
    userID = request.cookies.get("loggedUserID",None)
    print("User {} wants to remove item {} from wishlist.".format(userID,itemID))
    
    orclCursor = orclConnection.cursor()
    result = orclCursor.var(FIXED_CHAR)
    try:
        orclCursor.callproc('table_dml.delete_wishlist',[userID,itemID,result])
        if result.getvalue().startswith("T"):
            print("Item {} was deleted from user {}'s wishlist.".format(itemID,userID))
            return "Ok. The item {} was deleted from your wishlist.".format(itemID)
        else:
            print("Couldn't delete item {} from {}'s wishlist.".format(itemID,userID))
            return "Failure. Couldn't remove item {} from your wishlist.".format(itemID)
    except:
        e = sys.exc_info()[0]
        print("Database Error: {}".format(e.args))
        return "Exception occured:{}".format(e.args)
    return "Successfully failed."

@app.route('/removeReservation', methods=['DELETE'])
def removeReservation():
    aucID = request.headers.get('Aucid');
    userID = request.cookies.get("loggedUserID",None)
    print("User {} wants to cancel his reservation on {}.".format(userID,aucID))
    
    orclCursor = orclConnection.cursor()
    result = orclCursor.var(FIXED_CHAR)
    try:
        orclCursor.callproc('table_dml.DELETE_RESERVED_AUCTION',[aucID,userID,result])
        if result.getvalue().startswith("T"):
            print("Reservation on {} was deleted by user {}.".format(aucID,userID))
            return "Ok. The reservation on {} was canceled.".format(aucID)
        else:
            print("Couldn't delete item {} from {}'s wishlist.".format(aucID,userID))
            return "Failure. Couldn't cancel reservation on {}.".format(aucID)
    except:
        e = sys.exc_info()[0]
        print("Database Error: {}".format(e.args))
        return "Exception occured:{}".format(e.args)
    
    return "Successfully failed."

@app.route('/updatePassword', methods=['PUT'])
def updatePassword():
    userID = request.cookies.get("loggedUserID",None)
    oldPW = request.headers.get('oldPW',None)
    newPW = request.headers.get('newPW',None)
    if userID == None or oldPW == None or newPW == None :
        return "A parameter is null or could not be obtained. Failed to update pw."
    else:

        orclCursor = orclConnection.cursor()
        statement = "SELECT pw_hash,pw_salt, id FROM USERACCOUNTS WHERE ID={}".format(userID)
        orclCursor.execute(statement)
        result = orclCursor.fetchone()

        oldPWBytes = bytes(oldPW,encoding="utf-8")
        oldPWHashed = hashlib.pbkdf2_hmac('sha256', oldPWBytes, result[1], 100000)
        if (oldPWHashed == result[0]):
            #old password matches the one in the database
            #proceed to updating it.
            newPWBytes = bytes(newPW,encoding="utf-8")
            newPWHashed = hashlib.pbkdf2_hmac('sha256', newPWBytes, result[1], 100000)
            opRez = orclCursor.var(int)
            orclCursor.callproc('table_dml.update_user_pw',[userID,newPWHashed,opRez] )
            if opRez.getvalue() == 0:
                return "Ok. Password changed."
            else:
                return "Failed to update password."
        else:
            return "Failed to update password. Passwords don't match."

@app.route("/updateUserParam" , methods=["PUT"])
def updateParam():
    param = request.headers.get("param",None)
    newVal = request.headers.get("value",None)
    userID = request.cookies.get("loggedUserID",None)
    if param == None or newVal == None:
        return "Failed to update parameter."
    else:
        orclCursor = orclConnection.cursor()
        opRez = orclCursor.var(int)
        orclCursor.callproc('table_dml.update_user_param',[userID,param,newVal,opRez])
        if opRez.getvalue() == 0:
            return "Ok. {} changed.".format(param)
        else:
            return "Failed to update {}.".format(param)

@app.route("/sendEmails", methods=["GET"])
def sendEmails():
    userID = request.cookies.get("loggedUserID", None)
    userName = request.cookies.get("loggedUser",None)
    userEmail = request.headers.get("userEmail",None)
    if userEmail == None or userID == None or userName==None:
        print("userID: {}; userName: {}; userEmail: {}".format(userID,userName, userEmail))
        return "Failed to send email."

    senderEmail = "breaktdg@gmail.com"

    cursorOrcl = orclConnection.cursor()
    wlQ = """SELECT i.name, a.buyout_value, a.discount, a.timeleft FROM WISHLISTS W, ITEMS I, AUCTIONS A
        WHERE w.id_item=i.id AND a.id_item=w.id_item AND A.discount>10 AND w.notified_for_auction=0 AND w.id_user={}""".format(userID)
    cursorOrcl.execute(wlQ)
    results = cursorOrcl.fetchall()

    message = MIMEMultipart("alternative")
    message["Subject"] = "{} - AHST has found some deals!".format(userName)
    message["From"] = senderEmail
    message["To"] = userEmail

    html = """\
        <html>
          <body>
            <p>Hi there {}! <br>
               How are you? We at AHST hope you've had some jolly good holidays. To make them even better, we've found some deals for the items in your wishlist!<br\>
               Check these out!
            </p><br\>
        """.format(userName)
    for result in results:
        html = html + " <p> {} for just {} gold(s). That's a {} discount! Time left: {} </p>".format(result[0],(result[1]-result[1]%10000)/10000,result[2], result[3])

    html = html + "</body></html>"

    port = 465  # For SSL
    password = getpass("PW for gmail:")
    emailpart = MIMEText(html,"html")
    message.attach(emailpart)
    # Create a secure SSL context
    context = ssl.create_default_context()

    with smtplib.SMTP_SSL("smtp.gmail.com", port, context=context) as server:
        server.login(senderEmail, password)
        server.sendmail(senderEmail, userEmail, message.as_string())

    return "Ok. Emails sent."

