create or replace PACKAGE TABLE_DML AUTHID CURRENT_USER AS
    PROCEDURE INSERT_ITEM(itemID IN NUMBER, itemName IN VARCHAR2, estimatedValue IN NUMBER DEFAULT 0);
    PROCEDURE UPDATE_ITEM_NAME(itemID IN NUMBER, newName IN VARCHAR2);
	PROCEDURE UPDATE_ITEM_PRICE(itemID IN NUMBER, newPrice IN NUMBER);

    PROCEDURE INSERT_AUCTION(auctionID IN NUMBER, realm IN VARCHAR2, buyout NUMBER, currentBid IN NUMBER, timeleft IN VARCHAR2, itemID IN NUMBER);
    PROCEDURE DELETE_AUCTION(auctionID IN NUMBER);

    PROCEDURE INSERT_RESERVED_AUCTION(userName IN VARCHAR2, auctionID IN NUMBER, dateMade IN DATE, dateExpires IN DATE, assignedID OUT NUMBER);
    PROCEDURE DELETE_RESERVED_AUCTION(auctionID IN NUMBER, userID IN NUMBER, result OUT CHAR);

    PROCEDURE INSERT_USER(username IN VARCHAR2, email IN VARCHAR2, realm IN VARCHAR2, funds IN NUMBER DEFAULT 0, pwHash IN RAW, pwSalt IN RAW, assignedID OUT NUMBER);
    PROCEDURE DELETE_USER(userID IN NUMBER);
    PROCEDURE UPDATE_USER_PARAM(userID IN NUMBER, paramToUpdate IN VARCHAR2, newValue IN VARCHAR2, opRez OUT NUMBER);
    PROCEDURE UPDATE_USER_PW(userID IN NUMBER, newPassword IN RAW, opRez OUT NUMBER);

    PROCEDURE INSERT_WISHLIST(user_name IN VARCHAR2, itemID IN NUMBER, assignedID OUT NUMBER);
    PROCEDURE DELETE_WISHLIST(userID IN NUMBER, itemID in NUMBER, opRez out CHAR);
END;

create or replace PACKAGE BODY TABLE_DML IS

    PROCEDURE INSERT_ITEM(itemID IN NUMBER, itemName IN VARCHAR2, estimatedValue IN NUMBER DEFAULT 0 ) IS
    BEGIN
        INSERT INTO ITEMS VALUES(itemID, itemName, estimatedValue);
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

    PROCEDURE UPDATE_ITEM_NAME(itemID IN NUMBER, newName IN VARCHAR2) IS
    BEGIN
        UPDATE ITEMS SET ITEMS.name = newName WHERE ITEMS.id = itemID;
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            RAISE;
    END UPDATE_ITEM_NAME;

	PROCEDURE UPDATE_ITEM_PRICE(itemID IN NUMBER, newPrice IN NUMBER) IS
    BEGIN
        UPDATE ITEMS SET ITEMS.average_price = newPrice WHERE ITEMS.id = itemID;
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            RAISE;
    END UPDATE_ITEM_PRICE;

    PROCEDURE INSERT_AUCTION(auctionID IN NUMBER, realm IN VARCHAR2, buyout NUMBER, currentBid IN NUMBER, timeleft IN VARCHAR2, itemID IN NUMBER) IS
    BEGIN
        INSERT INTO AUCTIONS(ID_AUCTION, REALM, BUYOUT_VALUE, CURRENT_BID, TIMELEFT,ID_ITEM)
            VALUES(auctionID, realm, buyout,currentBid,timeleft,itemID);
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

    PROCEDURE INSERT_RESERVED_AUCTION(userName IN VARCHAR2, auctionID IN NUMBER, dateMade IN DATE, dateExpires IN DATE, assignedID OUT NUMBER) IS
        maxID NUMBER;
        userID NUMBER;
        alreadyExists NUMBER;
    BEGIN
        userID := 0;
        alreadyExists := 0;
        SELECT ua.ID INTO userID FROM USERACCOUNTS ua WHERE ua.username = userName;
        IF userID <> 0 THEN
            SELECT COUNT(*) INTO alreadyExists FROM RESERVED_AUCTIONS WHERE ID_AUCTION = auctionID;
            IF alreadyExists = 0 THEN
                maxID:=0;
                SELECT MAX(ID) INTO maxID FROM RESERVED_AUCTIONS;
                maxID := maxID + 1;
                INSERT INTO RESERVED_AUCTIONS(ID, ID_USER, ID_AUCTION, DATE_MADE, DATE_EXPIRES) VALUES (maxID, userID, auctionID, dateMade, dateExpires);
                assignedID := maxID;
                COMMIT;
            ELSE
                assignedID := null;
            END IF;
        ELSE
            assignedID :=null;
        END IF;
        EXCEPTION WHEN OTHERS THEN
            assignedID:=null;
            raise;
    END INSERT_RESERVED_AUCTION;

    PROCEDURE DELETE_RESERVED_AUCTION(auctionID IN NUMBER, userID IN NUMBER, result OUT CHAR) IS
    BEGIN
        DELETE FROM RESERVED_AUCTIONS WHERE id_auction=auctionID;
        result := 'T';
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            result := 'F';
            RAISE;    
    END DELETE_RESERVED_AUCTION;

    PROCEDURE INSERT_USER(username IN VARCHAR2, email IN VARCHAR2, realm IN VARCHAR2, funds IN NUMBER DEFAULT 0, pwHash IN RAW, pwSalt IN RAW, assignedID OUT NUMBER) IS
     maxID NUMBER;
    BEGIN
        maxID:=0;
        SELECT MAX(ID) INTO maxID FROM USERACCOUNTS;
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

    PROCEDURE UPDATE_USER_PARAM(userID IN NUMBER, paramToUpdate IN VARCHAR2, newValue IN VARCHAR2, opRez OUT NUMBER) IS
        command VARCHAR2(200);
    BEGIN
        IF LOWER(paramToUpdate) IN ('username', 'email', 'realm', 'funds') THEN 
            command := 'UPDATE USERACCOUNTS SET ' || LOWER(paramToUpdate) || '=''' || LOWER(newValue) || ''' WHERE id=' || userID;
            dbms_output.put_line('Comanda ce se va executa:' || command);
            EXECUTE IMMEDIATE command;
            opRez := 0;
            COMMIT;
        ELSE
            opRez := 99;
        END IF;
        EXCEPTION WHEN OTHERS THEN
            opRez := 99;
            RAISE;
    END UPDATE_USER_PARAM;

    PROCEDURE UPDATE_USER_PW(userID IN NUMBER, newPassword IN RAW, opRez OUT NUMBER) IS
    BEGIN
        UPDATE USERACCOUNTS SET pw_hash = newPassword WHERE id=userID;
        opRez :=0;
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            opRez :=99;
            RAISE;
    END UPDATE_USER_PW;

    PROCEDURE INSERT_WISHLIST(user_name IN VARCHAR2, itemID IN NUMBER, assignedID OUT NUMBER) IS
        maxID NUMBER;
        userID NUMBER;
        alreadyExists NUMBER;
    BEGIN
        userID :=0;
        alreadyExists :=0;
        SELECT UA.ID INTO userID FROM USERACCOUNTS UA WHERE UA.USERNAME=user_name;

        IF userID <> 0 THEN
            SELECT COUNT(*) INTO alreadyExists FROM WISHLISTS WHERE id_user = userID AND id_item = itemID;
            IF alreadyExists = 0 THEN
                maxID:=0;
                SELECT MAX(ID) INTO maxID FROM WISHLISTS;
                maxID :=maxID +1;
                INSERT INTO WISHLISTS(ID, ID_USER, ID_ITEM, NOTIFIED_FOR_AUCTION)
                    VALUES(maxID, userID, itemID, 0);
                assignedID := maxID;
                COMMIT;
            ELSE
                assignedID:=null;
            END IF;
        ELSE
            assignedID := null;
        END IF;
        EXCEPTION WHEN OTHERS THEN
            assignedID := null;
            RAISE;
    END INSERT_WISHLIST;

    PROCEDURE DELETE_WISHLIST(userID IN NUMBER, itemID in NUMBER, opRez out CHAR) IS 
    BEGIN
        DELETE FROM WISHLISTS W WHERE w.id_item = itemID AND w.id_user=userID;
        opRez := 'T';
        COMMIT;
        EXCEPTION WHEN OTHERS THEN
            opRez := 'F';
            RAISE;
    END DELETE_WISHLIST;

END TABLE_DML;

create or replace TRIGGER CALCULATE_DISCOUNT
		BEFORE INSERT ON AUCTIONS
		FOR EACH ROW
		DECLARE
			v_discount auctions.discount%TYPE;
			v_avg items.average_price%TYPE;
		BEGIN
                v_discount := 0.0;
				SELECT items.average_price INTO v_avg FROM ITEMS WHERE items.id = :NEW.ID_ITEM;
                IF v_avg IS NULL THEN
                    v_avg :=1.0;
                END IF;
				v_discount :=  (1.0 - (:NEW.BUYOUT_VALUE / v_avg )) * 100; 
				:NEW.DISCOUNT := v_discount;
END CALCULATE_DISCOUNT;