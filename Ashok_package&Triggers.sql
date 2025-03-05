CREATE OR REPLACE PACKAGE library_package AS
    PROCEDURE add_staff(p_staff_id NUMBER, p_sname VARCHAR2, p_designation VARCHAR2);
    PROCEDURE add_borrower(p_bname VARCHAR2, p_phno NUMBER, p_address VARCHAR2, p_date_of_subscription DATE); 
    PROCEDURE add_category(p_category_id NUMBER, p_cat_name VARCHAR2);
    PROCEDURE add_book(p_bookID NUMBER, p_title VARCHAR2, p_publisher VARCHAR2, p_category_id NUMBER, p_quantity NUMBER);
    PROCEDURE get_book_details(p_title VARCHAR2);
    PROCEDURE issue_book(p_bookID NUMBER, p_b_id NUMBER, p_staff_id NUMBER);
    PROCEDURE return_book(p_ts_id NUMBER, p_staff_id NUMBER, p_ret_date DATE);
END library_package;
/



CREATE OR REPLACE PACKAGE BODY library_package AS

    --- ADD STAFF PROCEDURE
    PROCEDURE add_staff(p_staff_id NUMBER,p_sname VARCHAR2, p_designation VARCHAR2) IS
        v_staff NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_staff FROM STAFF WHERE staff_id=p_staff_id;
        IF v_staff=0 THEN
            INSERT INTO STAFF(staff_id,sname,designation)
            VALUES(p_staff_id,p_sname,p_designation);
            DBMS_OUTPUT.PUT_LINE('A NEW STAFF MEMBER IS HIRED. Staffid - '||p_staff_id||' | Name - '||p_sname||' | Designation - '||p_designation);
        ELSE 
            RAISE_APPLICATION_ERROR(-20001,'A STAFF MEMBER WAS ALREADY ASSIGNED WITH THIS ID -'||p_staff_id);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR OCCURED WHILE ADDING STAFF | '||SQLERRM);
    END add_staff;
    
    --------------------------------------------------------------------------------------------------------------------------------- 
    --- ADD BORROWER PROCEDURE
    PROCEDURE add_borrower(p_bname VARCHAR2, p_phno NUMBER, p_address VARCHAR2, p_date_of_subscription DATE) IS
        v_ph_no BORROWER.ph_no%TYPE;
        v_b_id BORROWER.b_id%TYPE;
    BEGIN
        SELECT COUNT(*) INTO v_ph_no FROM BORROWER WHERE ph_no=p_phno;
        IF v_ph_no=0 THEN
            INSERT INTO BORROWER(bname, ph_no, address, date_of_subscription)
            VALUES(p_bname, p_phno, p_address,  p_date_of_subscription );
            SELECT b_id INTO v_b_id FROM BORROWER 
            WHERE bname=p_bname AND ph_no=p_phno; 
            DBMS_OUTPUT.PUT_LINE('BORROWER ADDED SUCCESSFULLY');
            DBMS_OUTPUT.PUT_LINE('ID     NAME      PHONE NUMBER      ADDRESS   DATE JOINED');
            DBMS_OUTPUT.PUT_LINE(v_b_id||'     '||p_bname||'     '|| p_phno||'     '|| p_address||'     '|| p_date_of_subscription);
        ELSE
           RAISE_APPLICATION_ERROR(-20002,'A BORROWER ALREADY EXISTS WITH SAME MOBILE NUMBER ');
        END IF;
    EXCEPTION 
        WHEN OTHERS THEN
             DBMS_OUTPUT.PUT_LINE('ERROR OCCURED WHILE ADDING BORROWER ACCOUNT | '||SQLERRM);
    END add_borrower;
    
    ---------------------------------------------------------------------------------------------------------------------------------  
    --- ADD CATEGORY PROCEDURE
    PROCEDURE add_category(p_category_id NUMBER, p_cat_name VARCHAR2) IS
    v_cat NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_cat FROM CATEGORY WHERE category_id=p_category_id;
        IF v_cat=0 THEN
            INSERT INTO CATEGORY(category_id,cat_name)
            VALUES(p_category_id,p_cat_name);
            DBMS_OUTPUT.PUT_LINE('CATEROGY '||p_cat_name||' ADDED SUCCESSFULLY');
        ELSE
            RAISE_APPLICATION_ERROR(-20003,'A CATEGORY ALREADY EXISTS WITH SAME ID');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR OCCURED WHILE ADDING CATEGORY |'||SQLERRM);
    END add_category;
    
    --------------------------------------------------------------------------------------------------------------------------------- 
    --- ADD BOOK PROCEDURE
    PROCEDURE add_book(p_bookID NUMBER, p_title VARCHAR2, p_publisher VARCHAR2, p_category_id NUMBER, p_quantity NUMBER) IS
    v_cat NUMBER;
    BEGIN 
        SELECT COUNT(*) INTO v_cat FROM CATEGORY WHERE category_id=p_category_id;
        IF v_cat=0 THEN
             RAISE_APPLICATION_ERROR(-20004,'CATEGORY ID '||p_category_id||' IS INCORRECT CHECK ONCE');
        ELSE
            INSERT INTO books values(p_bookID, p_title, p_publisher , p_category_id, p_quantity ); 
            DBMS_OUTPUT.PUT_LINE('BOOK '||p_title ||' ADDED SUCCESSFULLY');
        END IF;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
             DBMS_OUTPUT.PUT_LINE('Book ID ' || p_bookID || ' ALREADY EXISTS.');
        WHEN OTHERS THEN
              DBMS_OUTPUT.PUT_LINE('UNEXPECTED ERROR OCCURED WHILE ADDING BOOK | ' || SQLERRM);
    END add_book;
    
     --------------------------------------------------------------------------------------------------------------------------------- 
    ---PROCEDURE TO GET BOOK DETAILS
    PROCEDURE get_book_details(p_title VARCHAR2) IS
        CURSOR book_details_cursor IS 
            SELECT b.bookID, b.book_title, b.publisher, c.cat_name, b.quantity 
            FROM books b
            JOIN category c ON b.category_id = c.category_id
            WHERE LOWER(b.book_title) LIKE '%' || LOWER(p_title) || '%';
        TYPE books_data_type IS TABLE OF book_details_cursor%ROWTYPE;
        v_book_rec books_data_type;
    BEGIN
        OPEN book_details_cursor;
            FETCH book_details_cursor BULK COLLECT INTO v_book_rec;
        CLOSE book_details_cursor;
        IF v_book_rec.COUNT > 0 THEN
            FOR i IN 1..v_book_rec.COUNT LOOP
                DBMS_OUTPUT.PUT_LINE('Book ID: ' || v_book_rec(i).bookID);
                DBMS_OUTPUT.PUT_LINE('Title: ' || v_book_rec(i).book_title);
                DBMS_OUTPUT.PUT_LINE('Publisher: ' || v_book_rec(i).publisher);
                DBMS_OUTPUT.PUT_LINE('Category: ' || v_book_rec(i).cat_name);
                DBMS_OUTPUT.PUT_LINE('Quantity: ' || v_book_rec(i).quantity);
                DBMS_OUTPUT.PUT_LINE('--------------------------------------');
                END LOOP;
        ELSE
            RAISE_APPLICATION_ERROR(-20005, 'NO BOOKS FOUND WITH THE TITLE: ' || p_title);
        END IF;
    EXCEPTION 
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('ERROR WHILE FETCHING BOOK DETAILS | ' || SQLERRM);
    END get_book_details;

    
    --------------------------------------------------------------------------------------------------------------------------------- 
    --- PROCEDURE TO ISSUE BOOK
    PROCEDURE issue_book(p_bookID NUMBER, p_b_id NUMBER, p_staff_id NUMBER) IS
    v_quantity NUMBER;
    v_book_exists NUMBER;
    v_borrower_exists NUMBER;
    v_staff_exists NUMBER;
    v_loan_count NUMBER;
    v_penalty_count NUMBER;
    v_book_issued NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_book_exists FROM books WHERE bookID=p_bookID;
        IF v_book_exists=0 THEN
             RAISE_APPLICATION_ERROR(-20006,' CURRENTLY BOOK IS NOT AVAILABLE IN OUR LIBRARY ');
        END IF;
        SELECT COUNT(*) INTO v_borrower_exists FROM borrower WHERE b_id=p_b_id;
        IF v_borrower_exists=0 THEN
             RAISE_APPLICATION_ERROR(-20007,'BORROWER ACCOUNT DOESNOT EXISTS ');
        END IF;
        SELECT COUNT(*) INTO v_staff_exists FROM staff WHERE staff_id=p_staff_id;
        IF v_staff_exists=0 THEN
             RAISE_APPLICATION_ERROR(-20008,'INCORRECT STAFF DETAILS');
        END IF;
        SELECT COUNT(*) INTO v_loan_count FROM TRANSACTIONS WHERE b_id=p_b_id AND return_date is null;
        IF v_loan_count>=3 THEN
             RAISE_APPLICATION_ERROR(-20009,'CURRENTLY MORE THAN 3 BOOKS ARE ISSUED USING YOUR ACCOUNT. RETURN THEM IN ORDER TO BORROW MORE BOOKS');
        END IF;
        SELECT COUNT(*) INTO v_book_issued FROM TRANSACTIONS 
        WHERE b_id=p_b_id AND bookID=p_bookID AND status='ISSUED';
        IF v_book_issued>0 THEN
             RAISE_APPLICATION_ERROR(-20010,'SAME BOOK IS CURRENTLY ISSUED TO YOUR ACCOUNT. CANT ISSUE SAME BOOK CHOOSE ANOTHER');
        END IF;
        SELECT COUNT(*) INTO v_penalty_count FROM transactions WHERE b_id=p_b_id AND penalty_amount>0;
        IF v_penalty_count>1  THEN
             DBMS_OUTPUT.PUT_LINE('KINDLY RETURN BOOKS IN TIME INORDER TO AVOID THE PENALTY CHARGES');
        END IF;
        SELECT quantity INTO v_quantity FROM books WHERE bookID=p_bookID;
        IF v_quantity>0 THEN
            INSERT INTO transactions(bookID, b_id, staff_id, status) VALUES (p_bookID, p_b_id, p_staff_id, 'ISSUED');
            DBMS_OUTPUT.PUT_LINE('BOOK ISSUED SUCCESSFULLY');
            COMMIT;
        ELSE
             RAISE_APPLICATION_ERROR(-20011,'CURRENTLY NO COPIES ARE AVAILABLE. SELECT ANOTHER BOOK');
        END IF;
                
        EXCEPTION
            WHEN OTHERS THEN
                 DBMS_OUTPUT.PUT_LINE('UNEXPECTED ERROR OCCURED WHILE ISSUING BOOK | ' || SQLERRM);
     END issue_book;
    
    --------------------------------------------------------------------------------------------------------------------------------- 
    --PROCEDURE TO RETURN BOOK 
    PROCEDURE return_book(p_ts_id NUMBER,p_staff_id NUMBER,p_ret_date DATE) IS
        v_bookID NUMBER;
        v_due_date DATE;
        v_overdue_days NUMBER;
        v_penalty NUMBER;
     BEGIN
        SELECT due_date INTO v_due_date FROM transactions WHERE ts_id=p_ts_id;
        v_overdue_days := GREATEST(trunc(p_ret_date - v_due_date), 0);
        v_penalty:=v_overdue_days*10;-- penalty of 10 rupees per day 
        
        SELECT bookID INTO v_bookID FROM transactions WHERE ts_id=p_ts_id AND return_date is null;
        
        UPDATE transactions 
        SET return_date=p_ret_date, staff_id=p_staff_id,penalty_amount= v_penalty,status='RETURNED'  
        WHERE ts_id=p_ts_id;
        
        DBMS_OUTPUT.PUT_LINE('BOOK RETURNED SUCCESSFULLY');
        IF v_penalty>0 THEN
            DBMS_OUTPUT.PUT_LINE('PENALTY OF '||v_penalty||' WILL BE CHARGED BECAUSE THE BOOK WAS RETURNED '||v_overdue_days||' AFTER THE DUE DATE');
        END IF;
        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('TRANSACTION ID ' || p_ts_id || ' NOT FOUND OR BOOK WAS ALREADY RETURNED.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Unexpected Error while book return ' || SQLERRM);
    END return_book;
    

END library_package;
/




-- TRIGGER TO AUTO-INCREMENT BORROWER ID
CREATE OR REPLACE TRIGGER tr_b_id
BEFORE INSERT ON BORROWER
FOR EACH ROW 
WHEN (NEW.b_id IS NULL)
BEGIN
    SELECT se_b_id.NEXTVAL INTO :NEW.b_id FROM dual;
END;
/

-- TRIGGER TO AUTO-INCREMENT TRANSACTION ID
CREATE OR REPLACE TRIGGER tr_ts_id
BEFORE INSERT ON TRANSACTIONS
FOR EACH ROW 
WHEN (NEW.ts_id IS NULL)
BEGIN
    SELECT se_ts_id.NEXTVAL INTO :NEW.ts_id FROM dual;
END;
/

-- TRIGGER TO DECREASE BOOK QUANTITY ON ISSUE
CREATE OR REPLACE TRIGGER tr_decrease_quantity
AFTER INSERT ON TRANSACTIONS
FOR EACH ROW
WHEN (NEW.status = 'ISSUED')
BEGIN
    UPDATE BOOKS
    SET quantity = quantity - 1
    WHERE bookID = :NEW.bookID;
END;
/

-- TRIGGER TO INCREASE BOOK QUANTITY ON RETURN
CREATE OR REPLACE TRIGGER tr_increase_quantity
AFTER UPDATE ON TRANSACTIONS
FOR EACH ROW
WHEN (NEW.status = 'RETURNED' AND OLD.status = 'ISSUED')
BEGIN
    UPDATE BOOKS
    SET quantity = quantity + 1
    WHERE bookID = :NEW.bookID;
END;
/