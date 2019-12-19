CREATE OR REPLACE PACKAGE TABLE_DML AUTHID CURRENT_USER AS
    PROCEDURE INSERT_ITEM(itemID IN NUMBER, itemName IN VARCHAR2);
    PROCEDURE DELETE_ITEM(itemID IN NUMBER);
    PROCEDURE UPDATE_ITEM(itemID IN NUMBER, newName IN VARCHAR2);

    PROCEDURE INSERT_AUCTION(auctionID IN NUMBER, realm IN VARCHAR2, seller IN VARCHAR2, buyout NUMBER, currentBid IN NUMBER, estimatedValue IN NUMBER, timeleft IN VARCHAR2, itemID IN NUMBER);
    PROCEDURE DELETE_AUCTION(auctionID IN NUMBER);
    
    PROCEDURE INSERT_RESERVED_AUCTION(userID IN NUMBER, auctionID IN NUMBER, dateMade IN DATE, dateExpires IN DATE, assignedID OUT NUMBER);
    PROCEDURE DELETE_RESERVED_AUCTION(reservedAuctionID IN NUMBER);

    PROCEDURE INSERT_USER(username IN VARCHAR2, email IN VARCHAR2, realm IN VARCHAR2, funds IN NUMBER DEFAULT 0, pwHash IN RAW, pwSalt IN RAW, assignedID OUT NUMBER);
    PROCEDURE DELETE_USER(userID IN NUMBER);
    PROCEDURE UPDATE_USER_PARAM(userID IN NUMBER, paramToUpdate IN VARCHAR2, newValue IN VARCHAR2, opRez OUT BOOLEAN);
    
    PROCEDURE INSERT_WISHLIST(userID IN NUMBER, itemID IN NUMBER, assignedID OUT NUMBER);
    PROCEDURE DELETE_WISHLIST(wishlistID IN NUMBER);
END;
/
create or replace PACKAGE BODY TABLE_DML IS

    PROCEDURE INSERT_ITEM(itemID IN NUMBER, itemName IN VARCHAR2) IS
    BEGIN
        INSERT INTO ITEMS VALUES(itemID, itemName);
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            RAISE;
    END INSERT_ITEM;

    PROCEDURE DELETE_ITEM(itemID IN NUMBER) IS  
    BEGIN
        DELETE FROM ITEMS WHERE id = itemID;
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            RAISE;
    END DELETE_ITEM;

    PROCEDURE UPDATE_ITEM(itemID IN NUMBER, newName IN VARCHAR2) IS
    BEGIN
        UPDATE ITEMS SET ITEMS.name = newName WHERE ITEMS.id = itemID;
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            RAISE;
    END UPDATE_ITEM;

    PROCEDURE INSERT_AUCTION(auctionID IN NUMBER, realm IN VARCHAR2, seller IN VARCHAR2, buyout NUMBER, currentBid IN NUMBER, estimatedValue IN NUMBER, timeleft IN VARCHAR2, itemID IN NUMBER) IS
    BEGIN
        INSERT INTO AUCTIONS(ID_AUCTION, REALM, SELLER_NAME, BUYOUT_VALUE, CURRENT_BID, ESTIMATED_VALUE, TIMELEFT,ID_ITEM)
            VALUES(auctionID, realm, seller,buyout,currentBid,estimatedValue,timeleft,itemID);
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            RAISE;
    END INSERT_AUCTION;

    PROCEDURE DELETE_AUCTION(auctionID IN NUMBER) IS
    BEGIN
        DELETE FROM AUCTIONS WHERE id_auction = auctionID;
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            RAISE;
    END DELETE_AUCTION;

    PROCEDURE INSERT_RESERVED_AUCTION(userID IN NUMBER, auctionID IN NUMBER, dateMade IN DATE, dateExpires IN DATE, assignedID OUT NUMBER) IS
        maxID NUMBER;
    BEGIN
        SELECT COUNT(*) INTO maxID FROM RESERVED_AUCTIONS;
        maxID := maxID + 1;
        INSERT INTO RESERVED_AUCTIONS(ID, ID_USER, ID_AUCTION, DATE_MADE, DATE_EXPIRES) VALUES (maxID, userID, auctionID, dateMade, dateExpires);
        assignedID := maxID;
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            assignedID:=null;
            raise;
    END INSERT_RESERVED_AUCTION;

    PROCEDURE DELETE_RESERVED_AUCTION(reservedAuctionID IN NUMBER) IS
    BEGIN
        DELETE FROM RESERVED_AUCTIONS WHERE id = reservedAuctionID;
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            RAISE;    
    END DELETE_RESERVED_AUCTION;

    PROCEDURE INSERT_USER(username IN VARCHAR2, email IN VARCHAR2, realm IN VARCHAR2, funds IN NUMBER DEFAULT 0, pwHash IN RAW, pwSalt IN RAW, assignedID OUT NUMBER) IS
     maxID NUMBER;
    BEGIN
        SELECT COUNT(*) INTO maxID FROM USERACCOUNTS;
        maxID:= maxID + 1;
        INSERT INTO USERACCOUNTS(ID, USERNAME, EMAIL, REALM, FUNDS, PW_HASH, PW_SALT)
            VALUES(maxID,username,email,realm,funds,pwHash,pwSalt);
        assignedID:=maxID;
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            assignedID:=null;
            raise;
    END INSERT_USER;

    PROCEDURE DELETE_USER(userID IN NUMBER) IS
    BEGIN
        DELETE FROM USERACCOUNTS WHERE id=userID;   
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            RAISE;
    END DELETE_USER;

    PROCEDURE UPDATE_USER_PARAM(userID IN NUMBER, paramToUpdate IN VARCHAR2, newValue IN VARCHAR2, opRez OUT BOOLEAN) IS
        command VARCHAR2(200);
    BEGIN
        IF LOWER(paramToUpdate) IN ('username', 'email', 'realm', 'funds', 'pw_hash') THEN 
            command := 'UPDATE USERACCOUNTS SET ' || LOWER(paramToUpdate) || '=' || LOWER(newValue) || ' WHERE id=' || userID;
            dbms_output.put_line('Comanda ce se va executa:' || command);
            EXECUTE IMMEDIATE command;
            opRez := true;
            COMMIT;
        ELSE
            opRez := false;
        END IF;
        EXCEPTION WHEN OTHERS THEN
            opRez := false;
            RAISE;
    END UPDATE_USER_PARAM;

    PROCEDURE INSERT_WISHLIST(userID IN NUMBER, itemID IN NUMBER, assignedID OUT NUMBER) IS
        maxID NUMBER;
    BEGIN
        SELECT COUNT(*) INTO maxID FROM WISHLISTS;
        maxID :=maxID +1;
        INSERT INTO WISHLISTS(ID, ID_USER, ID_ITEM, NOTIFIED_FOR_AUCTION)
            VALUES(maxID, userID, itemID, 0);
        assignedID := maxID;
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            assignedID := null;
            RAISE;
    END INSERT_WISHLIST;

    PROCEDURE DELETE_WISHLIST(wishlistID IN NUMBER) IS 
    BEGIN
        DELETE FROM WISHLISTS WHERE id = wishlistID;
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            RAISE;
    END DELETE_WISHLIST;

END TABLE_DML;