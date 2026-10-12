USE DATABASE ADVISOR_COPILOT_DB;

-- Create the presentation schema for BI and AI tools
CREATE SCHEMA IF NOT EXISTS CURATED_DATA;
USE SCHEMA CURATED_DATA;

-- 1. Executive Global Performance View
-- Purpose: Aggregated single source of truth to evaluate global sales and AUM.
CREATE OR REPLACE VIEW vw_Exec_Global_Performance AS
SELECT 
    d.Year,
    d.Month,
    r.Region_Name,
    ac.Class_Name,
    SUM(f.EOM_Total_Value) AS Total_AUM,
    SUM(f.Net_Flow) AS Monthly_Net_Flow
FROM ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Fact_AUM_Monthly_Clean f
JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Date_Clean d ON f.Date_ID = d.Date_ID
JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Client_Clean c ON f.Client_ID = c.Client_ID
JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Advisor_Clean a ON c.Advisor_ID = a.Advisor_ID
JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Branch_Clean b ON a.Branch_ID = b.Branch_ID
JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Region_Clean r ON b.Region_ID = r.Region_ID
JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Fund_Clean fund ON f.Fund_ID = fund.Fund_ID
JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Asset_Class_Clean ac ON fund.Asset_Class_ID = ac.Asset_Class_ID
GROUP BY 
    d.Year, 
    d.Month, 
    r.Region_Name, 
    ac.Class_Name;

-- 2. Manager Operational Metrics View
-- Purpose: Branch-level reporting to highlight capacity constraints and churn risk, driving the "stagnation" narrative.
CREATE OR REPLACE VIEW vw_Manager_Operational_Metrics AS
SELECT 
    b.Branch_Name,
    a.Advisor_Name,
    a.Capacity_Status,
    COUNT(DISTINCT c.Client_ID) AS Total_Clients,
    AVG(c.Churn_Risk_Score) AS Avg_Churn_Risk,
    SUM(f.Net_Flow) AS Total_Net_Flows
FROM ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Advisor_Clean a
JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Branch_Clean b ON a.Branch_ID = b.Branch_ID
LEFT JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Client_Clean c ON a.Advisor_ID = c.Advisor_ID
LEFT JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Fact_AUM_Monthly_Clean f ON c.Client_ID = f.Client_ID
GROUP BY 
    b.Branch_Name, 
    a.Advisor_Name, 
    a.Capacity_Status;

-- 3. Advisor Client Prep View (Cortex Analyst Foundation)
-- Purpose: Flattened client portfolio data. The dynamic data masking applied earlier to Client_Name will automatically pass through this view!
CREATE OR REPLACE VIEW vw_Advisor_Client_Prep AS
SELECT 
    c.Client_ID,
    c.Client_Name,
    c.Risk_Tolerance,
    c.Target_Retirement_Year,
    a.Advisor_Name,
    acc.Account_Type,
    fund.Fund_Name,
    fund.Ticker,
    f.EOM_Total_Value AS Current_Value,
    f.Date_ID AS Last_Updated
FROM ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Client_Clean c
JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Advisor_Clean a ON c.Advisor_ID = a.Advisor_ID
JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Account_Clean acc ON c.Client_ID = acc.Client_ID
JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Fact_AUM_Monthly_Clean f ON c.Client_ID = f.Client_ID
JOIN ADVISOR_COPILOT_DB.STANDARDIZED_DATA.Dim_Fund_Clean fund ON f.Fund_ID = fund.Fund_ID
QUALIFY ROW_NUMBER() OVER (PARTITION BY c.Client_ID, acc.Account_ID, fund.Fund_ID ORDER BY f.Date_ID DESC) = 1;

-- Grant access to the Analyst role so the BI tools can query these views
GRANT SELECT ON ALL VIEWS IN SCHEMA ADVISOR_COPILOT_DB.CURATED_DATA TO ROLE ADVISOR_ANALYST_ROLE;