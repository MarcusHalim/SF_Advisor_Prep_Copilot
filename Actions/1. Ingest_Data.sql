USE DATABASE ADVISOR_COPILOT_DB;
USE SCHEMA RAW_DATA;

-- File Formats
CREATE FILE FORMAT IF NOT EXISTS my_csv_format TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"' NULL_IF = ('', 'NULL', 'nan');
CREATE FILE FORMAT IF NOT EXISTS my_json_format TYPE = JSON STRIP_OUTER_ARRAY = TRUE;

-- Create Internal Stage
CREATE STAGE IF NOT EXISTS MOCK_DATA_STAGE;

-- Create Dimension Tables
CREATE OR REPLACE TRANSIENT TABLE Dim_Region (Region_ID VARCHAR, Region_Name VARCHAR, Regional_VP VARCHAR);
CREATE OR REPLACE TRANSIENT TABLE Dim_Branch (Branch_ID VARCHAR, Region_ID VARCHAR, Branch_Name VARCHAR, Branch_Manager VARCHAR);
CREATE OR REPLACE TRANSIENT TABLE Dim_Advisor (Advisor_ID VARCHAR, Advisor_Name VARCHAR, Branch_ID VARCHAR, Hire_Date DATE, Capacity_Status VARCHAR);
CREATE OR REPLACE TRANSIENT TABLE Dim_Client (Client_ID VARCHAR, Advisor_ID VARCHAR, Client_Name VARCHAR, Risk_Tolerance VARCHAR, Target_Retirement_Year INT, Churn_Risk_Score FLOAT);
CREATE OR REPLACE TRANSIENT TABLE Dim_Account (Account_ID VARCHAR, Client_ID VARCHAR, Account_Type VARCHAR, Open_Date DATE);
CREATE OR REPLACE TRANSIENT TABLE Dim_Asset_Class (Asset_Class_ID VARCHAR, Class_Name VARCHAR, Risk_Tier VARCHAR);
CREATE OR REPLACE TRANSIENT TABLE Dim_Fund (Fund_ID VARCHAR, Fund_Name VARCHAR, Ticker VARCHAR, Asset_Class_ID VARCHAR, Expense_Ratio FLOAT);
CREATE OR REPLACE TRANSIENT TABLE Dim_Date (Date_ID DATE, Date DATE, Month INT, Quarter INT, Year INT);

-- Create Fact Tables (Clustered for BI Performance)
CREATE OR REPLACE TRANSIENT TABLE Fact_AUM_Monthly (AUM_ID VARCHAR, Client_ID VARCHAR, Fund_ID VARCHAR, Date_ID DATE, EOM_Total_Value FLOAT, Net_Flow FLOAT) CLUSTER BY (Date_ID);
CREATE OR REPLACE TRANSIENT TABLE Fact_Trades (Trade_ID VARCHAR, Account_ID VARCHAR, Fund_ID VARCHAR, Date_ID DATE, Trade_Type VARCHAR, Quantity FLOAT, Price FLOAT, Total_Value FLOAT, Status VARCHAR) CLUSTER BY (Date_ID);

-- Create Unstructured Document Tables
CREATE OR REPLACE TRANSIENT TABLE Doc_CRM_Notes (Note_ID VARCHAR, Client_ID VARCHAR, Advisor_ID VARCHAR, Interaction_Date DATE, Note_Text VARCHAR, Raw_JSON VARIANT);
CREATE OR REPLACE TRANSIENT TABLE Doc_Fund_Prospectus (Chunk_ID VARCHAR, Fund_ID VARCHAR, Doc_Type VARCHAR, Text_Chunk VARCHAR, Raw_JSON VARIANT);
CREATE OR REPLACE TRANSIENT TABLE Doc_Call_Transcripts (Transcript_ID VARCHAR, Client_ID VARCHAR, Advisor_ID VARCHAR, Call_Date DATE, Transcript_Text VARCHAR, Raw_JSON VARIANT);

-- Ingest Structured Data
COPY INTO Dim_Region FROM @mock_data_stage/Dim_Region.csv FILE_FORMAT = my_csv_format;
COPY INTO Dim_Branch FROM @mock_data_stage/Dim_Branch.csv FILE_FORMAT = my_csv_format;
COPY INTO Dim_Advisor FROM @mock_data_stage/Dim_Advisor.csv FILE_FORMAT = my_csv_format;
COPY INTO Dim_Client FROM @mock_data_stage/Dim_Client.csv FILE_FORMAT = my_csv_format;
COPY INTO Dim_Account FROM @mock_data_stage/Dim_Account.csv FILE_FORMAT = my_csv_format;
COPY INTO Dim_Asset_Class FROM @mock_data_stage/Dim_Asset_Class.csv FILE_FORMAT = my_csv_format;
COPY INTO Dim_Fund FROM @mock_data_stage/Dim_Fund.csv FILE_FORMAT = my_csv_format;
COPY INTO Dim_Date FROM @mock_data_stage/Dim_Date.csv FILE_FORMAT = my_csv_format;
COPY INTO Fact_AUM_Monthly FROM @mock_data_stage/Fact_AUM_Monthly.csv FILE_FORMAT = my_csv_format;
COPY INTO Fact_Trades FROM @mock_data_stage/Fact_Trades.csv FILE_FORMAT = my_csv_format;

-- Ingest Unstructured Data
COPY INTO Doc_CRM_Notes (Note_ID, Client_ID, Advisor_ID, Interaction_Date, Note_Text, Raw_JSON) FROM (SELECT $1:Note_ID::VARCHAR, $1:Client_ID::VARCHAR, $1:Advisor_ID::VARCHAR, $1:Interaction_Date::DATE, $1:Note_Text::VARCHAR, $1 FROM @mock_data_stage/Doc_CRM_Notes.json (FILE_FORMAT => 'my_json_format'));
COPY INTO Doc_Fund_Prospectus (Chunk_ID, Fund_ID, Doc_Type, Text_Chunk, Raw_JSON) FROM (SELECT $1:Chunk_ID::VARCHAR, $1:Fund_ID::VARCHAR, $1:Doc_Type::VARCHAR, $1:Text_Chunk::VARCHAR, $1 FROM @mock_data_stage/Doc_Fund_Prospectus.json (FILE_FORMAT => 'my_json_format'));
COPY INTO Doc_Call_Transcripts (Transcript_ID, Client_ID, Advisor_ID, Call_Date, Transcript_Text, Raw_JSON) FROM (SELECT $1:Transcript_ID::VARCHAR, $1:Client_ID::VARCHAR, $1:Advisor_ID::VARCHAR, $1:Call_Date::DATE, $1:Transcript_Text::VARCHAR, $1 FROM @mock_data_stage/Doc_Call_Transcripts.json (FILE_FORMAT => 'my_json_format'));