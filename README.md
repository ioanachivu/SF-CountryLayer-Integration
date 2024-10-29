# Salesforce Country Data Integration and Lead Management
This repository contains the implementation of a Salesforce solution to integrate country data using the CountryLayer API and manage lead information based on country details. The project includes the following key components:

## 1. Country Data Integration
API Integration: The CM_CountryService class fetches country information from the CountryLayer API (using a Named Credential), including fields such as Name, Alpha2Code, Alpha3Code, Capital City, Region, and RegionalBlocs.
Daily Update: A Schedulable class (CM_CountryServiceScheduler) ensures country data is updated daily. Any changes in the API are reflected in Salesforce.
Test Class: CM_CountryServiceTest mocks the API response and verifies both the insert and update logic for country records.

## 2. Lead Management Trigger
A lead trigger (CM_LeadTrigger) automatically populates lead records with country-related data based on the lead's country.
The CM_LeadHandler class fetches the country data from Salesforce and fills in fields like Alpha2Code, Alpha3Code, Capital City, Region, and RegionalBlocs.
Test coverage is provided in CM_LeadHandlerTest.

## 3. Validation Rule
A validation rule (PreventOwnerChange) ensures that the Lead Source, Country, and Number of Employees fields must be filled in before the Lead Owner can be changed. Exceptions are made for specific profiles (System Administrator and Contract Manager).

## 4. Flow
A flow tracks and records the timestamp when a Lead Owner is assigned, storing the date in the Owner Since field.

## 5. Deployment
All metadata, including custom objects, validation rules, triggers, and classes, are ready for deployment and can be found in the repository.

## 6. Testing
The solution includes comprehensive unit tests for API callouts, triggers, and validation rules, ensuring the system is fully testable and ready for deployment.
