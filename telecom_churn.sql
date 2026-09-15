CREATE DATABASE telecom_churn;
USE telecom_churn;

-- BASE VIEW
CREATE VIEW vw_base_telco_churn AS
SELECT 
	Customer_ID,
    Tenure,
    
    CASE
		WHEN Tenure <= 12 THEN '0-1 Year'
        WHEN Tenure <= 24 THEN '1-2 Years'
        WHEN Tenure <= 48 THEN '2-4 Years'
        ELSE '4+ Years'
	END AS Tenure_Group,
    
    Contract,
    Internet_Service,
    Payment_Method,
    Customer_Feedback,
    
    Monthly_Charges,
    Total_Charges,
    
    Churn_Status,
    Churn_Probability,
    Risk_Level
FROM customer_churn;

-- ANALYTICAL VIEWS
-- 1 Customer Risk Distribution
CREATE VIEW vw_customer_risk_dist AS
SELECT Risk_level, COUNT(*) AS Customer_Count
FROM vw_base_telco_churn
GROUP BY Risk_Level;

-- 2 Average Churn Probability by Risk Level
CREATE VIEW vw_average_churn_probability_by_risk AS
SELECT
	Risk_level,
    ROUND(AVG(Churn_Probability), 3) AS Avg_Churn_Probability
FROM vw_base_telco_churn
GROUP BY Risk_Level;

-- 3 Churn by Contract Type
CREATE OR REPLACE VIEW vw_churn_by_contracttype AS
SELECT
	Contract,
    Churn_Status,
    COUNT(*) AS Total_Customers
FROM vw_base_telco_churn
GROUP BY Contract, Churn_Status;

-- 4 Churn by Tenure Group
CREATE OR REPLACE VIEW vw_churn_by_tenure_group AS
SELECT
	Tenure_Group,
    Churn_Status,
    COUNT(*) AS Total_Customers
FROM vw_base_telco_churn
GROUP BY Tenure_Group, Churn_Status;

-- 5 High Risk Customers
CREATE OR REPLACE VIEW vw_high_risk_telcocustomers AS 
SELECT
	Customer_ID,
    Customer_Feedback,
    Contract,
    Internet_Service,
    Monthly_Charges,
    Total_Charges,
    Tenure,
    Churn_Probability,
    Risk_Level
FROM vw_base_telco_churn
WHERE Risk_Level = 'High Risk'
ORDER BY Churn_Probability DESC;

-- 6 Customer Feedback vs Churn
CREATE VIEW vw_customerfeedback_churn AS
SELECT
	Customer_Feedback,
    Churn_Status,
    COUNT(*) AS Customer_Count
FROM vw_base_telco_churn
GROUP BY Customer_Feedback, Churn_Status;

-- KPI VIEWS
-- 1 Total Customers
CREATE VIEW vw_kpi_total_telcocustomers AS
SELECT COUNT(*) AS Total_Customers
FROM vw_base_telco_churn;

-- 2 High Risk Customers
CREATE OR REPLACE VIEW vw_kpi_high_risk_telcocustomers AS
SELECT COUNT(*) AS High_Risk_Customers
FROM vw_base_telco_churn
WHERE Risk_Level = 'High Risk';

-- 3 Average Churn Probability
CREATE VIEW vw_kpi_average_churn_probability AS
SELECT ROUND(AVG(Churn_Probability), 3) AS Avg_Churn_Probability
FROM vw_base_telco_churn;

-- 4 Estimated Churn Rate
CREATE VIEW vw_kpi_customerchurn_rate AS
SELECT
	ROUND((SUM(CASE WHEN Churn_Probability >= 0.5 THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Churn_Rate_Percentage
FROM vw_base_telco_churn;

    