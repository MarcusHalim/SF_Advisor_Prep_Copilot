USE DATABASE ADVISOR_COPILOT_DB;
USE SCHEMA STANDARDIZED_DATA;

-- 1. Establish Role-Based Access Control (RBAC)
-- Create roles to separate standard analysts from compensation/admin users
CREATE ROLE IF NOT EXISTS ADVISOR_ANALYST_ROLE;
CREATE ROLE IF NOT EXISTS SENIOR_COMP_ADMIN_ROLE;

-- Grant usage on database and schema
GRANT USAGE ON DATABASE ADVISOR_COPILOT_DB TO ROLE ADVISOR_ANALYST_ROLE;
GRANT USAGE ON SCHEMA ADVISOR_COPILOT_DB.STANDARDIZED_DATA TO ROLE ADVISOR_ANALYST_ROLE;

GRANT USAGE ON DATABASE ADVISOR_COPILOT_DB TO ROLE SENIOR_COMP_ADMIN_ROLE;
GRANT USAGE ON SCHEMA ADVISOR_COPILOT_DB.STANDARDIZED_DATA TO ROLE SENIOR_COMP_ADMIN_ROLE;

-- 2. Create Dynamic Data Masking Policies
-- This policy masks string data for anyone who is not a Senior Admin or AccountAdmin
CREATE OR REPLACE MASKING POLICY pii_string_mask AS (val string) RETURNS string ->
  CASE
    WHEN CURRENT_ROLE() IN ('SENIOR_COMP_ADMIN_ROLE', 'ACCOUNTADMIN') THEN val
    ELSE '***MASKED_PII***'
  END;

-- 3. Apply Masking Policies to the Curated Tables
-- Securing the Client Name just as you secured advisor tax and compensation records
ALTER TABLE Dim_Client_Clean MODIFY COLUMN Client_Name SET MASKING POLICY pii_string_mask;

-- Grant select access to the analyst role so they can query the table (but see masked data)
GRANT SELECT ON TABLE Dim_Client_Clean TO ROLE ADVISOR_ANALYST_ROLE;