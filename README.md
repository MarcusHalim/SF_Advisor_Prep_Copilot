# SF_Advisor_Prep_Copilot
This project is an end-to-end BI/AI analytics pipeline in Snowflake. The scripts ingest and cleanse raw data into Snowflake, handling errors and missing data. These feed views which will support multiple BI dashboards. Both the structured and unstructured data are used to support various within a GenAI agent in Snowflake.

I pushed this line from Snowflake.

I pushed this line back to snowflake.

## Explanation of Structure
### Folders

Sample Scripts - SQL/Python Scripts to execute if you prefer not to use the UI to complete actions in Snowflake UI.

## Instructions for executing this project in Snowflake.

1. Create Git Repo
2. Generate Git Repo Personal Access Token (PAT)
3. Create Git Workspace in Snowflake and Connect to your Repo
4. Create ADVISOR_DB in Snowflake and RAW_DATA schema in ADVISOR_DB
5. Execute 2.Generate_Mock_Data.ipynb to create all 13 needed sample data files within the mock_data folder in Sample_Scripts OR use the data files that are already present.
6. Create the stage for the raw data within ADVISOR_DB.RAW_DATA--Select Server side encryption so that we can use Cortex AI Functions later.
