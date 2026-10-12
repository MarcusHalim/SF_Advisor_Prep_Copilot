USE DATABASE ADVISOR_COPILOT_DB;
CREATE SCHEMA IF NOT EXISTS STANDARDIZED_DATA;
USE SCHEMA STANDARDIZED_DATA;

-- 1. Cleanse Dim_Client (Handling Nulls and standardizing risk scores)
CREATE OR REPLACE TRANSIENT TABLE Dim_Client_Clean AS
SELECT 
    Client_ID,
    Advisor_ID,
    Client_Name,
    UPPER(Risk_Tolerance) AS Risk_Tolerance, -- Standardization
    COALESCE(Target_Retirement_Year, 2050) AS Target_Retirement_Year, -- Handling the injected NULLs
    ROUND(Churn_Risk_Score, 2) AS Churn_Risk_Score
FROM ADVISOR_COPILOT_DB.RAW_DATA.Dim_Client;

-- 2. Cleanse Fact_AUM_Monthly (Ensuring no negative AUM due to generation errors)
CREATE OR REPLACE TRANSIENT TABLE Fact_AUM_Monthly_Clean AS
SELECT 
    AUM_ID,
    Client_ID,
    Fund_ID,
    Date_ID,
    IFF(EOM_Total_Value < 0, 0, EOM_Total_Value) AS EOM_Total_Value, -- Data Quality Rule
    Net_Flow
FROM ADVISOR_COPILOT_DB.RAW_DATA.Fact_AUM_Monthly;

-- Note: In a full enterprise script, we would create clean versions of ALL raw tables here.

-- 3. Import all other tables as is to standard layer --- implement deeper data quality checks in a later iteration

CREATE OR REPLACE TRANSIENT TABLE Dim_Account_Clean AS
SELECT *    
FROM ADVISOR_COPILOT_DB.RAW_DATA.Dim_Account;

CREATE OR REPLACE TRANSIENT TABLE Dim_Advisor_Clean AS
SELECT *    
FROM ADVISOR_COPILOT_DB.RAW_DATA.Dim_Advisor;

CREATE OR REPLACE TRANSIENT TABLE Dim_Asset_Class_Clean AS
SELECT *    
FROM ADVISOR_COPILOT_DB.RAW_DATA.Dim_Asset_Class;

CREATE OR REPLACE TRANSIENT TABLE Dim_Branch_Clean AS
SELECT *    
FROM ADVISOR_COPILOT_DB.RAW_DATA.Dim_Branch;

CREATE OR REPLACE TRANSIENT TABLE Dim_Date_Clean AS
SELECT *    
FROM ADVISOR_COPILOT_DB.RAW_DATA.Dim_Date;

CREATE OR REPLACE TRANSIENT TABLE Dim_Fund_Clean AS
SELECT *    
FROM ADVISOR_COPILOT_DB.RAW_DATA.Dim_Fund;

CREATE OR REPLACE TRANSIENT TABLE Dim_Region_Clean AS
SELECT *    
FROM ADVISOR_COPILOT_DB.RAW_DATA.Dim_Region;

CREATE OR REPLACE TRANSIENT TABLE Doc_Call_Transcripts_Clean AS
SELECT *    
FROM ADVISOR_COPILOT_DB.RAW_DATA.Doc_Call_Transcripts;

CREATE OR REPLACE TRANSIENT TABLE Doc_CRM_Notes_Clean AS
SELECT *    
FROM ADVISOR_COPILOT_DB.RAW_DATA.Doc_CRM_Notes;

CREATE OR REPLACE TRANSIENT TABLE Doc_Fund_Prospectus_Clean AS
SELECT *    
FROM ADVISOR_COPILOT_DB.RAW_DATA.Doc_Fund_Prospectus;

CREATE OR REPLACE TRANSIENT TABLE Fact_Trades_Clean AS
SELECT *    
FROM ADVISOR_COPILOT_DB.RAW_DATA.Fact_Trades;
