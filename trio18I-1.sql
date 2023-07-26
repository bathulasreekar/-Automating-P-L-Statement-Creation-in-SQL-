
/*
========================================================================================
========================================================================================
======================TRIO-18==========================================================
=========================================================================================
==========================P/L Statement=================================================
*/
USE H_Accounting;

DELIMITER $$


DROP PROCEDURE IF EXISTS H_Accounting.trio18I $$ -- COMMENT THIS ONCE USED

CREATE PROCEDURE H_Accounting.trio18I(IN FN_YEAR INT) -- creates a new SP

	READS SQL DATA -- reading the data
BEGIN                                           -- template BEGINS here

#COMBINING ALL THE TABLES USING UNION.



#FINDING THE SUM OF REVENUE.

SELECT statement_section AS Description, IFNULL(FORMAT(SUM(jeli.credit),2),0) AS Amount
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 68
AND YEAR(je.entry_date) = FN_YEAR

UNION ALL


#OBTAINING DATA FOR RETURN AND RETURN AND REFUND

SELECT statement_section AS Description, IFNULL(FORMAT(SUM(jeli.credit),2),0) AS Amount
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 69
AND YEAR(je.entry_date) = FN_YEAR

UNION

#COST OF GOODS SOLD

SELECT statement_section AS Description, IFNULL(FORMAT(SUM(jeli.credit),2),0) AS Amount
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 74
AND YEAR(je.entry_date) = FN_YEAR
UNION

#REVENUE SUM

SELECT 'GROSS PROFIT' AS Description, IFNULL(FORMAT((
SELECT SUM(jeli.credit)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 68
AND YEAR(je.entry_date) = FN_YEAR
)
 - 
(
SELECT SUM(jeli.credit)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 74
AND YEAR(je.entry_date) = FN_YEAR
)
,2),0)AS Amount
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id IN (68,69,74)
AND is_balance_sheet_section = 0
   AND cancelled = 0
   AND debit_credit_balanced = 1
AND YEAR(je.entry_date) = FN_YEAR
UNION

#GENERAL EXPENSES

SELECT statement_section AS Description, IFNULL(FORMAT(SUM(jeli.credit),2),0) AS Amount
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 75
AND YEAR(je.entry_date) = FN_YEAR

UNION

#SELLING EXPENSES

SELECT statement_section AS Description, IFNULL(FORMAT(SUM(jeli.credit),2),0) AS Amount
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 76
AND YEAR(je.entry_date) = FN_YEAR

UNION

#OPERATING EXPENSES
SELECT 'OPERATING PROFIT' AS Description, IFNULL(FORMAT((
SELECT SUM(jeli.credit)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 68
AND YEAR(je.entry_date) = FN_YEAR
) 
- 
(
SELECT SUM(jeli.credit)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 74
AND YEAR(je.entry_date) = FN_YEAR
) 
-
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 75
AND YEAR(je.entry_date) = FN_YEAR
) 
-
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 76
AND YEAR(je.entry_date) = FN_YEAR
)
,2),0)AS Amount
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id IN (68,69,74,75,76)
AND is_balance_sheet_section = 0
   AND cancelled = 0
   AND debit_credit_balanced = 1
AND YEAR(je.entry_date) = FN_YEAR

UNION

#OTHER EXPENSES
SELECT statement_section AS Description, IFNULL(FORMAT(SUM(jeli.credit),2),0) AS Amount
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 77
AND YEAR(je.entry_date) = FN_YEAR

UNION

#OTHER INCOME
SELECT statement_section AS Description, IFNULL(FORMAT(SUM(jeli.credit),2),0) AS Amount
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 78
AND YEAR(je.entry_date) = FN_YEAR

UNION

#EARNING BEFORE TAX

SELECT 'EARNING BEFORE TAX' AS Description, IFNULL(FORMAT((
SELECT SUM(jeli.credit)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 68
AND YEAR(je.entry_date) = FN_YEAR
) 
- 
(
SELECT SUM(jeli.credit)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 74
AND YEAR(je.entry_date) = FN_YEAR
) 
-
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 75
AND YEAR(je.entry_date) = FN_YEAR
) 
-
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 76
AND YEAR(je.entry_date) = FN_YEAR
)
-
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 77
AND YEAR(je.entry_date) = FN_YEAR
)
+
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 78
AND YEAR(je.entry_date) = FN_YEAR
)
,2),0)AS Amount
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id IN (68,69,74,75,76,77,78)
AND is_balance_sheet_section = 0
   AND cancelled = 0
   AND debit_credit_balanced = 1
AND YEAR(je.entry_date) = FN_YEAR

UNION

#INCOME TAX

SELECT statement_section AS Description, IFNULL(FORMAT(SUM(jeli.credit),2),0) AS Amount
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 79
AND YEAR(je.entry_date) = FN_YEAR

UNION

#OTHER TAX

SELECT statement_section AS Description, IFNULL(FORMAT(SUM(jeli.credit),2),0) AS Amount
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 80
AND YEAR(je.entry_date) = FN_YEAR
UNION
SELECT 'NET INCOME' AS Description, IFNULL(FORMAT((
SELECT SUM(jeli.credit)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 68
AND YEAR(je.entry_date) = FN_YEAR
) - 
(
SELECT SUM(jeli.credit)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 74
AND YEAR(je.entry_date) = FN_YEAR
) -(
SELECT IFNULL(SUM(jeli.credit),0)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 75
AND YEAR(je.entry_date) = FN_YEAR
) -
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 76
AND YEAR(je.entry_date) = FN_YEAR
)-
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 77
AND YEAR(je.entry_date) = FN_YEAR
)
+
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 78
AND YEAR(je.entry_date) = FN_YEAR
)-
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 79
AND YEAR(je.entry_date) = FN_YEAR
)
,2),0)AS Amount
FROM `account` AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id IN (68,69,74,75,76,77,78,79)
AND is_balance_sheet_section = 0
   AND cancelled = 0
   AND debit_credit_balanced = 1
AND YEAR(je.entry_date) = FN_YEAR;

END$$       -- template ENDs here
DELIMITER ;

CALL H_Accounting.trio18I(2015);