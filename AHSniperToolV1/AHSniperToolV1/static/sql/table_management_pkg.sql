CREATE OR REPLACE PACKAGE TABLE_MANAGEMENT AUTHID CURRENT_USER AS
    PROCEDURE CREATE_TABLES;
    PROCEDURE DELETE_TABLES;
    PROCEDURE RESET_TABLES;
END;
/
CREATE OR REPLACE PACKAGE BODY TABLE_MANAGEMENT IS
   PROCEDURE CREATE_TABLES IS
    command varchar2(500);
   BEGIN
    
    command := 'CREATE TABLE auctions (
    id_auction        INTEGER NOT NULL,
    realm             VARCHAR2(30 CHAR) NOT NULL,
	discount		  NUMBER(10,2),
    buyout_value      INTEGER NOT NULL,
    current_bid       INTEGER NOT NULL,
    timeleft          VARCHAR2(15 CHAR) NOT NULL,
    id_item           INTEGER NOT NULL
)';
    EXECUTE IMMEDIATE command;
    
    command := 'ALTER TABLE auctions ADD CONSTRAINT auctions_pk PRIMARY KEY ( id_auction )';
    EXECUTE IMMEDIATE command;
    
    command := 'CREATE TABLE items (
    id     INTEGER NOT NULL,
    name   VARCHAR2(100 CHAR) NOT NULL,
	average_price NUMBER(38,0) DEFAULT 0
)';
    EXECUTE IMMEDIATE command;
    
    command := 'ALTER TABLE items ADD CONSTRAINT items_pk PRIMARY KEY ( id )';
    EXECUTE IMMEDIATE command;
    
    command := 'CREATE TABLE reserved_auctions (
    id             INTEGER NOT NULL,
    id_user        INTEGER NOT NULL,
    id_auction     INTEGER NOT NULL,
    date_made      DATE NOT NULL,
    date_expires   DATE NOT NULL
)';
    EXECUTE IMMEDIATE command;
    
    command := 'ALTER TABLE reserved_auctions ADD CONSTRAINT reserved_auctions_pk PRIMARY KEY ( id )';
    EXECUTE IMMEDIATE command;
    
    command := 'CREATE TABLE useraccounts (
    id         INTEGER NOT NULL,
    username   VARCHAR2(50 CHAR) UNIQUE NOT NULL,
    email      VARCHAR2(50 CHAR) UNIQUE NOT NULL,
    realm      VARCHAR2(30 CHAR),
    funds      INTEGER,
    pw_hash    RAW(32) NOT NULL,
    pw_salt    RAW(32) NOT NULL
)';
    EXECUTE IMMEDIATE command;
    
    command := 'ALTER TABLE useraccounts ADD CONSTRAINT user_pk PRIMARY KEY ( id )';
    EXECUTE IMMEDIATE command;
    
    command := 'CREATE TABLE wishlists (
    id                     INTEGER NOT NULL,
    id_user                INTEGER NOT NULL,
    id_item                INTEGER NOT NULL,
    notified_for_auction   INTEGER
)';
    EXECUTE IMMEDIATE command;
    
    command := 'ALTER TABLE wishlists ADD CONSTRAINT wishlists_pk PRIMARY KEY ( id )';
    EXECUTE IMMEDIATE command;
    
    command := 'ALTER TABLE auctions
    ADD CONSTRAINT auctions_items_fk FOREIGN KEY ( id_item )
        REFERENCES items ( id )
            ON DELETE CASCADE';
    EXECUTE IMMEDIATE command;
    
    command := 'ALTER TABLE reserved_auctions
    ADD CONSTRAINT reserved_auctions_auctions_fk FOREIGN KEY ( id_auction )
        REFERENCES auctions ( id_auction )
            ON DELETE CASCADE';
    EXECUTE IMMEDIATE command;
    
    command := 'ALTER TABLE reserved_auctions
    ADD CONSTRAINT reserved_auctions_user_fk FOREIGN KEY ( id_user )
        REFERENCES useraccounts ( id )
            ON DELETE CASCADE';
    EXECUTE IMMEDIATE command;
    
    command := 'ALTER TABLE wishlists
    ADD CONSTRAINT wishlists_items_fk FOREIGN KEY ( id_item )
        REFERENCES items ( id )
            ON DELETE CASCADE';
    EXECUTE IMMEDIATE command;
    
    command := 'ALTER TABLE wishlists
    ADD CONSTRAINT wishlists_user_fk FOREIGN KEY ( id_user )
        REFERENCES useraccounts ( id )
            ON DELETE CASCADE';
    EXECUTE IMMEDIATE command;

   END CREATE_TABLES;

   PROCEDURE DELETE_TABLES IS
   BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE auctions CASCADE CONSTRAINTS';
        
        EXECUTE IMMEDIATE 'DROP TABLE items CASCADE CONSTRAINTS';
        
        EXECUTE IMMEDIATE 'DROP TABLE reserved_auctions CASCADE CONSTRAINTS';
        
        EXECUTE IMMEDIATE 'DROP TABLE useraccounts CASCADE CONSTRAINTS';
        
        EXECUTE IMMEDIATE 'DROP TABLE wishlists CASCADE CONSTRAINTS';
   EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;

   END DELETE_TABLES;
   
   PROCEDURE RESET_TABLES IS
   BEGIN
        DELETE_TABLES;
        CREATE_TABLES;
    END RESET_TABLES;
END TABLE_MANAGEMENT;