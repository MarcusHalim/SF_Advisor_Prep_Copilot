-- 1. Create a database and schema for the project
CREATE DATABASE IF NOT EXISTS ADVISOR_COPILOT_DB;
USE DATABASE ADVISOR_COPILOT_DB;
CREATE SCHEMA IF NOT EXISTS RAW_DATA;
USE SCHEMA RAW_DATA;

-- 2. Create the Secret for GitHub Authentication
CREATE OR REPLACE SECRET github_secret
  TYPE = PASSWORD
  USERNAME = '<your_github_username>'
  PASSWORD = '<your_pat>';

-- 3. Create the API Integration
CREATE OR REPLACE API INTEGRATION github_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/<your_github_username>')
  ALLOWED_AUTHENTICATION_SECRETS = ('ADVISOR_COPILOT_DB.RAW_DATA.github_secret')
  ENABLED = TRUE;

-- 4. Create the Git Repository Stage
CREATE OR REPLACE GIT REPOSITORY advisor_git_repo
  API_INTEGRATION = github_integration
  GIT_CREDENTIALS = github_secret
  ORIGIN = 'https://github.com/<your_github_username>/SF_Advisor_Prep_Copilot.git';