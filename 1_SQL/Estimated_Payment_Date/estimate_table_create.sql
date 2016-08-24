/* 
Create table script for Estimated Payment and Supplier Onboard Date


*/

-- Insert statements
-- Append SELECT statements after

-- Update archive table
INSERT INTO XXFB.XXFB_SC_INV_ESTPAYDATE_ARCHIVE
(
  INVOICE_ID
, ESTIMATED_PAYMENT_DATE
, ML_VERSION 
, CREATED_DATE
, CREATED_BY 
, LAST_UPDATED_DATE
, LAST_UPDATED_BY
)
SELECT 
  INVOICE_ID
, ESTIMATED_PAYMENT_DATE
, ML_VERSION 
, CREATED_DATE
, CREATED_BY 
, LAST_UPDATED_DATE
, LAST_UPDATED_BY
FROM XXFB.XXFB_SC_INV_ESTPAYDATE
WHERE INVOICE_ID || CREATED_DATE NOT IN (SELECT DISTINCT INVOICE_ID || CREATED_DATE FROM XXFB.XXFB_SC_INV_ESTPAYDATE_ARCHIVE)

-- Truncate table
TRUNCATE TABLE XXFB.XXFB_SC_INV_ESTPAYDATE


-- Estimated payment date 
DROP TABLE XXFB.XXFB_SC_INV_ESTPAYDATE;
CREATE TABLE XXFB.XXFB_SC_INV_ESTPAYDATE
(
  INVOICE_ID NUMBER(9) NOT NULL
, ACTUAL_ESTIMATED_PAYMENT_DATE DATE NOT NULL
, ESTIMATE_RMS NUMBER(9,4)
, ESTIMATED_PAYMENT_DATE DATE NOT NULL
, ML_VERSION VARCHAR(10) NOT NULL
, CREATED_DATE DATE NOT NULL
, CREATED_BY NUMBER(9) NOT NULL
, LAST_UPDATED_DATE DATE
, LAST_UPDATED_BY NUMBER(9)
);
 
CREATE INDEX XXFB.XXFB_SC_INV_ESTPAYDATE_IDX ON XXFB.XXFB_SC_INV_ESTPAYDATE (INVOICE_ID);

CREATE TABLE XXFB.XXFB_SC_INV_ESTPAYDATE_ARCHIVE
(
  INVOICE_ID NUMBER(9) NOT NULL
, ACTUAL_ESTIMATED_PAYMENT_DATE TIMESTAMP NOT NULL
, ESTIMATE_RMS NUMBER(9,4)
, ESTIMATED_PAYMENT_DATE TIMESTAMP NOT NULL
, ML_VERSION VARCHAR(10) NOT NULL
, CREATED_DATE TIMESTAMP NOT NULL
, CREATED_BY NUMBER(9) NOT NULL
, LAST_UPDATED_DATE TIMESTAMP
, LAST_UPDATED_BY NUMBER(9)
);

CREATE INDEX XXFB.XXFB_SC_INV_ESTPAYDATE_AR_IDX ON XXFB.XXFB_SC_INV_ESTPAYDATE_ARCHIVE (INVOICE_ID);

-- Estimated onboard date table
CREATE TABLE XXFB.XXFB_SC_SUP_ESTONBOARDDATE
(
  REQUEST_ID NUMBER NOT NULL
, ESTIMATED_ONBOARD_DATE DATE NOT NULL
, ESTIMATE_RMS NUMBER
, ML_VERSION NUMBER NOT NULL
, CREATED_DATE DATE NOT NULL
, CREATED_BY NUMBER NOT NULL
, LAST_UPDATED_DATE DATE
, LAST_UPDATED_BY NUMBER
);

CREATE INDEX XXFB.XXFB_SC_SUP_ESTONBOARDDATE_IDX ON XXFB.XXFB_SC_SUP_ESTONBOARDDATE (REQUEST_ID);

CREATE TABLE XXFB.XXFB_SC_SUP_ESTONBOARDDATE_AR
(
  REQUEST_ID NUMBER NOT NULL
, ESTIMATED_ONBOARD_DATE DATE NOT NULL
, ESTIMATE_RMS NUMBER
, ML_VERSION NUMBER NOT NULL
, CREATED_DATE DATE NOT NULL
, CREATED_BY NUMBER NOT NULL
, LAST_UPDATED_DATE DATE
, LAST_UPDATED_BY NUMBER
);

CREATE INDEX XXFB.XXFB_SC_SUP_ESTONBDATE_AR_IDX ON XXFB.XXFB_SC_SUP_ESTONBOARDDATE_AR (REQUEST_ID);


-- Update active table
INSERT INTO XXFB.XXFB_SC_INV_ESTPAYDATE
(
  INVOICE_ID
, ESTIMATED_PAYMENT_DATE
, ML_VERSION 
, CREATED_DATE
, CREATED_BY 
, LAST_UPDATED_DATE
, LAST_UPDATED_BY
)


-- Update archive table
INSERT INTO XXFB.XXFB_SC_SUP_ESTONBOARDDATE_AR
(
  REQUEST_ID
, ESTIMATED_ONBOARD_DATE 
, ML_VERSION
, CREATED_DATE
, CREATED_BY 
, LAST_UPDATED_DATE
, LAST_UPDATED_BY 
)
SELECT 
  REQUEST_ID
, ESTIMATED_ONBOARD_DATE 
, ML_VERSION
, CREATED_DATE
, CREATED_BY 
, LAST_UPDATED_DATE
, LAST_UPDATED_BY 
FROM XXFB.XXFB_SC_SUP_ESTONBOARDDATE
WHERE REQUEST_ID || CREATED_DATE NOT IN (SELECT DISTINCT REQUEST_ID || CREATED_DATE FROM XXFB.XXFB_SC_SUP_ESTONBOARDDATE_AR)

-- Truncate table
TRUNCATE TABLE XXFB.XXFB_SC_SUP_ESTONBOARDDATE

-- Update active table
INSERT INTO XXFB.XXFB_SC_SUP_ESTONBOARDDATE
(
  REQUEST_ID
, ESTIMATED_ONBOARD_DATE 
, ML_VERSION
, CREATED_DATE
, CREATED_BY 
, LAST_UPDATED_DATE
, LAST_UPDATED_BY 
)