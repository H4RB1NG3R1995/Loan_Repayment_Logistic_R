# Loan_Repayment_Logistic_R
Prediction of Loan Repayment of the Lending Club using Binary Logistic Regression Model

About the data
In the lending industry, investors provide loans to borrowers in exchange for the promise of repayment with interest. If the borrower repays the loan, then the lender profits from the interest. However, if the borrower is unable to repay the loan, then the lender loses money. Therefore, lenders face the problem of predicting the risk of a borrower being unable to repay a loan. To address this problem, we will use publicly available data from LendingClub.com, a website that connects borrowers and investors over the Internet. This dataset represents 9,578 3-year loans that were funded through the LendingClub.com platform between May 2007 and February 2010. The binary dependent variable not_fully_paid indicates that the loan was not paid back in full (the borrower either defaulted or the loan was "charged off," meaning the borrower was deemed unlikely to ever pay it back). 

To predict this dependent variable, we will use the following independent variables available to the investor when deciding whether to fund a loan: 

1. credit.policy: 1 if the customer meets the credit underwriting criteria of LendingClub.com, and 0 otherwise. 
2. purpose: The purpose of the loan (takes values "credit_card", "debt_consolidation", "educational", "major_purchase", "small_business", and "all_other"). 
3. int.rate: The interest rate of the loan, as a proportion (a rate of 11% would be stored as 0.11). Borrowers judged by LendingClub.com to be more risky are assigned higher interest rates. 
4. installment: The monthly installments ($) owed by the borrower if the loan is funded. 
5. log.annual.inc: The natural log of the self-reported annual income of the borrower. 
6. dti: The debt-to-income ratio of the borrower (amount of debt divided by annual income). 
7. fico: The FICO credit score of the borrower. 
8. days.with.cr.line: The number of days the borrower has had a credit line. 
9. revol.bal: The borrower's revolving balance (amount unpaid at the end of the credit card billing cycle).
10. revol.util: The borrower's revolving line utilization rate (the amount of the credit line used relative to total credit available). 
11. inq.last.6mths: The borrower's number of inquiries by creditors in the last 6 months. 
12. delinq.2yrs: The number of times the borrower had been 30+ days past due on a payment in the past 2 years. 
13. pub.rec: The borrower's number of derogatory public records (bankruptcy filings, tax liens, or judgments).

Problem Statement: Build an analytical model to predict Loan Repayment of the Lending Club.

For this classification problem, Binary Logistic Regression Model is used for prediction.

Significant variables:

1. Positively significant: Purpose (Small Business), installment, revol.bal, inq.last.6mths
2. Negatively Significant: Purpose (Credit Card, Debt_consolidation), log.annual.inc, fico
