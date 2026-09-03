# From childhood to Young Adulthood: Understanding Cancer Incidence Patterns in England

## Project Overview

This project analyses cancer incidence patterns among children and young people aged 0-24 in England.

The analysis focuses on:

1. Age profiles and cancer type composition
2. Geographic variation across NHS England regions
3. Changes in incidence patterns between 2013 and 2022

## Project Structure
cyp-cancer-incidence-england/

├── 0_data/                 # Data folder

├── 1_notebooks/            # Jupyter notebooks for data cleaning and analysis (in progress)

├── 2_sql/                  # SQL queries for structured data analysis (in progress)

├── 3_output/               # Dashboard and insight summary (in progress)

├── requirements.txt        # Python dependencies

└── README.md

## Data Sources

- **National dataset: NDRS Cancer Incidence and Mortality Dashboard**
    England-level data where each row represents a unique aggregated observation defined by year, gender, age group at diagnosis (Under 1, 1-4, 5-9, 10-14, 15-19, 20-24), and NDRS cancer classification. Coverage: 2013-2022

- **Regional dataset: NDRS Cancer Incidence and Mortality Dashboard**
    NHS England region-level data where each row represents a unique aggregated observation defined by year, gender, NHS region, and NDRS cancer classification. Age group aggregated to 0-24. Coverage: 2013-2022

- **Geographic levels consideration for regional analysis:**
    Regional analysis uses NHS England Region level (7 regions), which provides sufficient case volumes for meaningful comparison of cancer incidence patterns across the 0-24 age group. Finer geographic levels (e.g. ICB, UTLA, LAUA) were considered but rejected due to small number suppression risk for rare cancer types in the CYP age group.

**Note:**
- Both datasets use NDRS Cancer Group classification, which might differs some published research using ICD-10 based cancer groups classification for general adult cancer statistic. Direct comparison with other publications should be made with caution. 
- Data is England-specific and excludes Scotland, Wales, and Northern Ireland.
- NHS cancer registration data is published in aggregated form - no individual patient records are used or accessible in this analysis.
- Incidence rates and confidence intervals are suppressed (represented as [u]) where the underlying count is fewer than 3.
- Counts themselves are published for all records. Rate-based analysis is therefore restricted to records with published numerical estimates; suppressed rates are not interpreted as zero and are excluded from rate calculations.

## Data Validation Findings

The national dataset contains 15,480 records after filtering to the CYP 0-24 age group.

Key findings from validation:
- **Classification change (2018):** The NDRS detailed field shows a structural change from 2018 onwards - 'Cardia and oesophagogastric junction' was split into two separate categories. The NDRS main classification remains consistent. This is documented and accounted for in trend analysis at the detailed cancer type level.

- **Suppressed values:** Incidence rates and confidence intervals are suppressed ([u]) for 11,869 of 15,480 records, primarily in younger age groups and rarer cancer types where counts fall below 33. Counts are available for all records. Analysis uses counts where rates are suppressed; rate-based analysis is restricted to records with published numerical estimates. Suppressed values are not interpreted as zeros.

- **Complete core fields:** All analytical dimensions (year, gender, age group, cancer classification) are fully populated with no standard missing values.

## Tools

- Python
- Pandas
- SQL
- Power BI

## Project Status

**Notebook 01 - Data Validation & Quality Assessment: In progress**
- Structural validation, schema checks, coverage analysis, suppression mapping, and classification consistency review completed for national dataset.

**Planned:**
- Analysis notebooks
- SQL queries
- Power BI dashboard
- one-page insight summary