
--- Staff Table
CREATE TABLE STAFF(
    staff_id NUMBER PRIMARY KEY, 
    sname VARCHAR2(50) NOT NULL,
    designation VARCHAR2(20)
);

--- Category Table
CREATE TABLE CATEGORY(
    category_id NUMBER PRIMARY KEY,
    cat_name VARCHAR2(30)
);

--- Borrowers Table  
CREATE SEQUENCE se_b_id START WITH 500 INCREMENT BY 1;

CREATE TABLE BORROWER(
    b_id NUMBER PRIMARY KEY,
    bname VARCHAR2(50) NOT NULL,
    ph_no NUMBER(10) NOT NULL,
    address VARCHAR2(100) NOT NULL,
    date_of_subscription DATE DEFAULT SYSDATE
);

--- Books Table
CREATE TABLE BOOKS(
    bookID NUMBER PRIMARY KEY,
    book_title VARCHAR2(50) NOT NULL,
    publisher VARCHAR2(30) NOT NULL,
    category_id NUMBER,
    quantity NUMBER,
    CONSTRAINT fk_cat_id FOREIGN KEY (category_id) REFERENCES CATEGORY(category_id)
);

--- Transactions Table
CREATE SEQUENCE se_ts_id START WITH 1001 INCREMENT BY 1;

CREATE TABLE TRANSACTIONS(
    ts_id NUMBER PRIMARY KEY,
    bookID NUMBER,
    b_id NUMBER,
    issue_date DATE DEFAULT SYSDATE,
    due_date DATE DEFAULT SYSDATE + 7,
    return_date DATE,
    penalty_amount NUMBER(10,2) DEFAULT 0,
    status VARCHAR2(10) DEFAULT 'ISSUED',
    staff_id NUMBER, 
    last_updated_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_borrower FOREIGN KEY (b_id) REFERENCES BORROWER(b_id),
    CONSTRAINT fk_book FOREIGN KEY (bookID) REFERENCES BOOKS(bookID),
    CONSTRAINT fk_staff FOREIGN KEY (staff_id) REFERENCES STAFF(staff_id)
);


