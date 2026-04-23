# Project Brief

## Project name
Healthcare Operations Analytics

## Domain
NHS elective care / waiting times / operational performance

## Core business problem
How do waiting times, backlog, and provider performance evolve over time, and where are the main operational bottlenecks?

## Candidate data source
NHS England RTT Waiting Times monthly releases, especially provider-level data files.

## Why this project
This project is intended to demonstrate:
- raw ingestion from recurring public releases
- cleaning and standardization of monthly files
- cloud data warehousing in BigQuery
- dbt model layering
- business-facing operational marts
- analytical storytelling around service performance

## Target analytical questions
1. How do monthly waiting times evolve by provider and specialty?
2. Which specialties accumulate the highest backlog?
3. Which providers deteriorate or improve the fastest over time?
4. Is higher demand associated with worse performance?
5. Where are the main operational bottlenecks?

## Planned layers
- raw landing files
- cleaned base tables
- dbt staging models
- dbt intermediate models
- dbt marts
- lightweight dashboard

## Initial deliverables
- reproducible repo structure
- raw data ingestion and normalization
- first BigQuery dataset
- first dbt models
- first dashboard