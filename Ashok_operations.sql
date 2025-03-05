
---ADD STAFF (ID, NAME, DESIGNATION)
BEGIN
    library_package.add_staff(1,'ASHOK','OWNER');
END;


--- BORROWER ID IS AUTO GENERATED WITH HELP OF SEQUENCE AND TRIGGER IT STARTS FROM 500
--- (BORROWER NAME, PHONE NUMBER, ADDRESS, DATE OF SUBSCRIPTION)
BEGIN
    library_package.add_borrower('USER',7095439779,'VIJAYAWADA',SYSDATE);
END;


---ADD CATEGORY. CATEGORY START WITH 100
--- (CATEGORY ID, CATEGORY NAME)
BEGIN
    library_package.add_category(101,'SCIENCE');
END;


--- ADD BOOK. BOOK ID START FROM 200
--- BOOK(ID, TITLE, PUBLISHER, CATEGORY, QUANTITY)
BEGIN
    library_package.add_book(200,'MYSTERY OF UNIVERSE','ABC PUBLISHERS',101,5);
END;


---GET AVAIALBLE BOOKS DETAILS BASED ON PARTIAL TITLE
BEGIN
    library_package.get_book_details('MYS');
END;


--- ISSUE BOOKS TO BORROWER BY USING(BOOK_ID, BORROWER_ID,STAFF_ID)
BEGIN
library_package.issue_book(200,500,1);
END;


SELECT * FROM BOOKS;

SELECT * FROM TRANSACTIONS;


--- RETURN BOOK BACK TO LIBRARY 
--- ENTER ( TRANSACTION ID, STAFF_ID, RETURN DATE)
BEGIN
library_package.return_book(1005,1,sysdate+1);
END;




----USER INPUT BASED OPERATIONS

-- ADD STAFF DETAILS
DECLARE 
    v_staff_id STAFF.staff_id%TYPE :=&staffID;
    v_sname STAFF.sname%type :='&name';
    v_desig STAFF.designation%type:='&desig';
BEGIN
    library_package.add_staff(v_staff_id,v_sname,v_desig);
    SELECT * FROM STAFF;
END;


-- ADD BOOROWER DETAILS
DECLARE 
    v_bname BORROWER.bname%TYPE :='&borrower_name';
    v_phno BORROWER.ph_no%TYPE := &phno;
    v_address BORROWER.address%TYPE :='&address';
    v_date_of_subscription BORROWER.date_of_subscription%TYPE :=&date_of_subscription;
BEGIN
    library_package.add_borrower(v_bname, v_phno, v_address,v_date_of_subscription );

END;
SELECT * FROM BORROWER;

-- ADD CATEGORY DETAILS
DECLARE 
    v_category_id CATEGORY.category_id%TYPE := &category_id;
    v_cat_name CATEGORY.cat_name%TYPE := '&category_name';
BEGIN
    library_package.add_category(v_category_id, v_cat_name);
END;


-- ADD BOOK DETAILS
DECLARE 
    v_bookID BOOKS.bookID%TYPE := &bookID;
    v_title BOOKS.book_title%TYPE := '&title';
    v_publisher BOOKS.publisher%TYPE := '&publisher';
    v_category_id BOOKS.category_id%TYPE := &category_id;
    v_quantity BOOKS.quantity%TYPE := &quantity;
BEGIN
    library_package.add_book(v_bookID, v_title, v_publisher, v_category_id, v_quantity);
END;


-- GET AVAILABLE BOOKS DETAILS BASED ON PARTIAL TITLE
DECLARE 
    v_title BOOKS.book_title%TYPE := '&partial_title';
BEGIN
    library_package.get_book_details(v_title);
END;


-- ISSUE BOOK TO BORROWER 
DECLARE 
    v_bookID TRANSACTIONS.bookID%TYPE := &bookID;
    v_borrower_id TRANSACTIONS.b_id%TYPE := &borrower_id;
    v_staff_id TRANSACTIONS.staff_id%TYPE := &staff_id;
BEGIN
    library_package.issue_book(v_bookID, v_borrower_id, v_staff_id);
END;


-- RETURN BOOK TO LIBRARY
DECLARE 
    v_ts_id TRANSACTIONS.ts_id%TYPE := &transaction_id;
    v_staff_id TRANSACTIONS.staff_id%TYPE := &staff_id;
    v_ret_date TRANSACTIONS.return_date%TYPE := &return_date;
BEGIN
    library_package.return_book(v_ts_id, v_staff_id, v_ret_date);
END;






--- ALL TABLES SELECT STATEMENTS
SELECT * FROM STAFF;
SELECT * FROM BORROWER;
SELECT * FROM CATEGORY;
SELECT * FROM BOOKS;
SELECT * FROM TRANSACTIONS;




--- DROP TABLES AND SEQUENCES
DROP TABLE TRANSACTIONS;
DROP TABLE BOOKS;
DROP TABLE BORROWER;
DROP TABLE CATEGORY;
DROP TABLE STAFF;

DROP SEQUENCE se_b_id;
DROP SEQUENCE se_ts_id;

