/*
========================================================================================
========================================================================================
======================TRIO-18==========================================================
=========================================================================================
==========================P/L Statement=================================================
=========================Balance sheet===================================================
=========================Comparison to present and past years===========================
*/



USE H_Accounting;

DROP PROCEDURE IF EXISTS H_Accounting.trio18II;
DELIMITER $$
CREATE PROCEDURE H_Accounting.trio18II(IN FN_YEAR INT) -- creates a new SP

	READS SQL DATA -- reading the data
BEGIN 

#ADDING NEW COLUMNS AND JOINING THE TABLES
 
Select
Case When Statement in ( 'REVENUE',
'RETURNS, REFUNDS, DISCOUNTS',
'COST OF GOODS AND SERVICES',
'GROSS PROFIT',
'ADMINISTRATIVE EXPENSES',
'SELLING EXPENSES',
'OPERATING PROFIT',
'OTHER EXPENSES',
'OTHER INCOME',
'EARNING BEFORE TAX',
'INCOME TAX',
'OTHER TAX',
'NET INCOME')
then 'PL'
WHEN Statement in  ('CURRENT ASSETS', 'CURRENT LIABILITIES','EQUITY') THEN 'BS'
else '' end as 'BS or PL',
ifnull(Statement,'') AS 'STATEMENT',
ifnull(Round(Amount_year_user_0,2),'') as 'FINANCIAL YEAR 1',
ifnull(Round(Amount_year_user_1,2),'') as 'FINANCIAL YEAR 2',
ifnull(Round((Amount_year_user_0-Amount_year_user_1)/Amount_year_user_0,2),'')as 'PERCENTAGE DIFFERENCE BETWEEN FIN_YEAR1 AND FIN_YEAR_2'
from
((Select
Statement_year_user_0 as Statement,
Amount_year_user_0,
Amount_year_user_1,
(Amount_year_user_0-Amount_year_user_1)/Amount_year_user_0

from(
(SELECT 
    statement_section AS Statement_year_user_0,
    FORMAT((IFNULL(SUM(credit),0)),0) as Amount_year_user_0
FROM journal_entry_line_item as jel
JOIN `account`  ac  USING (account_id)
JOIN  statement_section ss ON ss.statement_section_id = ac.balance_sheet_section_id
JOIN  journal_entry  je USING(journal_entry_id)
WHERE is_balance_sheet_section = 1
   AND cancelled = 0
   AND debit_credit_balanced = 1
   AND YEAR(je.entry_date) = FN_YEAR
   GROUP BY statement_section_order, statement_section_code, Statement_year_user_0
ORDER BY statement_section_order) as BL_year_user_0
inner join
(SELECT 
    statement_section AS Statement_year_user_1,
    FORMAT((IFNULL(SUM(credit),0)),0) as Amount_year_user_1
FROM journal_entry_line_item as jel
JOIN `account`  ac  USING (account_id)
JOIN  statement_section ss ON ss.statement_section_id = ac.balance_sheet_section_id
JOIN  journal_entry  je USING(journal_entry_id)
WHERE is_balance_sheet_section = 1
   AND cancelled = 0
   AND debit_credit_balanced = 1
   AND YEAR(je.entry_date) = (FN_YEAR-1)
   GROUP BY statement_section_order, statement_section_code, Statement_year_user_1
ORDER BY statement_section_order) as BL_year_user_1
on BL_year_user_0.Statement_year_user_0 = BL_year_user_1.Statement_year_user_1))

UNION

(SELECT 
null AS 'STATEMENT',
null as 'FINANCIAL YEAR 1',
null as 'FINANCIAL YEAR 2',
null as 'PERCENTAGE DIFFERENCE BETWEEN FIN_YEAR1 AND FIN_YEAR_2')
UNION
(select 
distinct(Account_year_user ) `Account`,
Amount_year_user ,
Amount_year_user_1,
(Amount_year_user_1-Amount_year_user )/(Amount_year_user_1)
from(
Select * from(
SELECT statement_section AS Account_year_user , FORMAT(SUM(jeli.credit),2) AS Amount_year_user 
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 68
AND YEAR(je.entry_date) = FN_YEAR 

UNION

#OBTAINING DATA FOR RETURN AND RETURN AND REFUND

SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
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

SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
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
SELECT 'GROSS PROFIT' AS Account, FORMAT((
SELECT SUM(jeli.credit)
FROM account AS acc
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
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 74
AND YEAR(je.entry_date) = FN_YEAR 
)
,2)AS Amount
FROM account AS acc
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

SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
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

SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
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

SELECT 'OPERATING PROFIT' AS Account, FORMAT((
SELECT SUM(jeli.credit)
FROM account AS acc
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
FROM account AS acc
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
FROM account AS acc
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
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 76
AND YEAR(je.entry_date) = FN_YEAR 
)
,2)AS Amount
FROM account AS acc
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
SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
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
SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
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

SELECT 'EARNING BEFORE TAX' AS Account, FORMAT((
SELECT SUM(jeli.credit)
FROM account AS acc
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
FROM account AS acc
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
FROM account AS acc
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
FROM account AS acc
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
FROM account AS acc
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
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 78
AND YEAR(je.entry_date) = FN_YEAR 
)
,2)AS Amount
FROM account AS acc
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
SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
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
SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 80
AND YEAR(je.entry_date) = FN_YEAR 

UNION

SELECT 'NET INCOME' AS Account, FORMAT((
SELECT SUM(jeli.credit)
FROM account AS acc
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
FROM account AS acc
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
FROM account AS acc
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
FROM account AS acc
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
FROM account AS acc
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
FROM account AS acc
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
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 79
AND YEAR(je.entry_date) = FN_YEAR 
)
,2)AS Amount
FROM account AS acc
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
AND YEAR(je.entry_date) = FN_YEAR )as PL_year_user 
left join
(SELECT statement_section AS Account_year_user_1, FORMAT(SUM(jeli.credit),2) AS Amount_year_user_1
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 68
AND YEAR(je.entry_date) = (FN_YEAR-1)

UNION 

#OBTAINING DATA FOR RETURN AND RETURN AND REFUND
SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 69
AND YEAR(je.entry_date) = (FN_YEAR-1)

UNION

#COST OF GOODS SOLD
SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 74
AND YEAR(je.entry_date) = (FN_YEAR-1)

UNION

#REVENUE SUM
SELECT 'GROSS PROFIT' AS Account, FORMAT((
SELECT SUM(jeli.credit)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 68
AND YEAR(je.entry_date) = (FN_YEAR-1)
) - 
(
SELECT SUM(jeli.credit)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 74
AND YEAR(je.entry_date) = (FN_YEAR-1)
)
,2)AS Amount
FROM account AS acc
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
AND YEAR(je.entry_date) = (FN_YEAR-1)

UNION

#GENERAL EXPENSES

SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 75
AND YEAR(je.entry_date) = (FN_YEAR-1)

UNION

#SELLING EXPENSES

SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 76
AND YEAR(je.entry_date) = (FN_YEAR-1)

UNION

#OPERATING EXPENSES

SELECT 'OPERATING PROFIT' AS Account, FORMAT((
SELECT SUM(jeli.credit)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 68
AND YEAR(je.entry_date) = (FN_YEAR-1)
) - 
(
SELECT SUM(jeli.credit)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 74
AND YEAR(je.entry_date) = (FN_YEAR-1)
) -(
SELECT IFNULL(SUM(jeli.credit),0)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 75
AND YEAR(je.entry_date) = (FN_YEAR-1)
) -
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 76
AND YEAR(je.entry_date) = (FN_YEAR-1)
)
,2)AS Amount
FROM account AS acc
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
AND YEAR(je.entry_date) = (FN_YEAR-1)

UNION

#OTHER EXPENSES

SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 77
AND YEAR(je.entry_date) = (FN_YEAR-1)

UNION

#OTHER INCOME

SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 78
AND YEAR(je.entry_date) = (FN_YEAR-1)

UNION

#EARNING BEFORE TAX

SELECT 'EARNING BEFORE TAX' AS Account, FORMAT((
SELECT SUM(jeli.credit)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 68
AND YEAR(je.entry_date) = (FN_YEAR-1)
) - 
(
SELECT SUM(jeli.credit)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 74
AND YEAR(je.entry_date) = (FN_YEAR-1)
) -(
SELECT IFNULL(SUM(jeli.credit),0)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 75
AND YEAR(je.entry_date) = (FN_YEAR-1)
) -
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 76
AND YEAR(je.entry_date) = (FN_YEAR-1)
)-
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 77
AND YEAR(je.entry_date) = (FN_YEAR-1)
)
+
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 78
AND YEAR(je.entry_date) = (FN_YEAR-1)
)
,2)AS Amount
FROM account AS acc
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
AND YEAR(je.entry_date) = (FN_YEAR-1)

UNION

#INCOME TAX

SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 79
AND YEAR(je.entry_date) = (FN_YEAR-1)

UNION

#OTHER TAX

SELECT statement_section AS Account, FORMAT(SUM(jeli.credit),2) AS Amount
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 80
AND YEAR(je.entry_date) = (FN_YEAR-1)
UNION
SELECT 'NET INCOME' AS Account, FORMAT((
SELECT SUM(jeli.credit)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 68
AND YEAR(je.entry_date) = (FN_YEAR-1)
) - 
(
SELECT SUM(jeli.credit)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 74
AND YEAR(je.entry_date) = (FN_YEAR-1)
) -(
SELECT IFNULL(SUM(jeli.credit),0)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 75
AND YEAR(je.entry_date) = (FN_YEAR-1)
) -
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 76
AND YEAR(je.entry_date) = (FN_YEAR-1)
)-
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 77
AND YEAR(je.entry_date) = (FN_YEAR-1)
)
+
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 78
AND YEAR(je.entry_date) = (FN_YEAR-1)
)-
(
SELECT IFNULL(SUM(jeli.credit),0)
FROM account AS acc
INNER JOIN statement_section AS ss
ON acc.profit_loss_section_id = ss.statement_section_id
INNER JOIN journal_entry_line_item AS jeli
USING(account_id)
INNER JOIN journal_entry AS je
USING(journal_entry_id)
WHERE acc.profit_loss_section_id = 79
AND YEAR(je.entry_date) = (FN_YEAR-1)
)
,2)AS Amount
FROM account AS acc
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
AND YEAR(je.entry_date) = (FN_YEAR-1))as PL_year_user_1
on PL_year_user .Account_year_user  = PL_year_user_1.Account_year_user_1) as Final )) as BL_PL;

END$$       -- template ENDs here
DELIMITER ;

Call H_Accounting.trio18II(2019);