# Collections-Analytics-Assignment

Data Analyst assignment: collections performance, data quality, recovery analysis, and ₹10 Cr investment recommendation.

## Project Overview

This project analyses a synthetic collections dataset to understand data quality issues, payment recovery, campaign attribution, timezone inconsistencies, agent identity, portfolio mix, and the reported month-on-month recovery improvement.

## Part 1 - Golden Dataset

### Data Exploration

The raw data contains 17 analytical datasets along with a data dictionary.

Initial data quality checks identified:
- Exact duplicate rows in borrowers, calls, payments, and whatsapp_events.
- Missing values across several tables.
- Missing payment references in some payment records.
- Multiple identifiers and repeated foreign keys across different tables.

### Cleaning Performed

The Golden Dataset was created by removing exact duplicate rows while retaining valid records with missing non-key information.

Rows removed:

| Table | Raw Rows | Golden Rows | Rows Removed |
|---|---:|---:|---:|
| borrowers | 30,600 | 30,000 | 600 |
| calls | 91,350 | 90,079 | 1,271 |
| payments | 25,500 | 25,014 | 486 |
| whatsapp_events | 60,600 | 60,000 | 600 |

No exact duplicate rows remain in the Golden Dataset.

Missing payment references were not automatically treated as invalid payments because missing reference values were present across different payment statuses.

The cleaned data is stored in the `golden_datasets/` folder.

## Part 2 - Data Forensics

### 1. Duplicate Payments

The raw payments table contains duplicate payment records.

- 972 rows are involved in duplicate payment groups.
- 486 extra rows remain after keeping one copy of each exact duplicate.
- Duplicate rows represent approximately 1.95% of the total raw payment amount.

The duplicate records include SUCCESS, FAILED, PENDING, and REVERSED payment statuses.

### 2. Payment Attribution

Payment attribution was investigated by linking payments to the most recent call for the same account before the payment.

Results:

- Total payments analysed: 25,014
- Payments attributed to a previous call: 17,025
- Unattributed payments: 7,989

The average attribution lag was approximately 44 days and the median lag was approximately 33 days.

Attribution-window analysis showed:

| Attribution Window | Payments Within Window |
|---|---:|
| 7 days | 8.94% |
| 14 days | 16.64% |
| 30 days | 31.45% |
| 60 days | 49.67% |

This indicates that reported recovery can be sensitive to the attribution window used.

### 3. Timezone Problems

A major timezone inconsistency was identified between the timezone stored in the calls table and the timezone configured for the corresponding vendor.

- Total calls: 90,079
- Timezone matched vendor master: 30,001 (33.31%)
- Timezone mismatched vendor master: 60,078 (66.69%)

Mismatch patterns included:

| Stored Timezone | Vendor Timezone | Calls |
|---|---|---:|
| Asia/Kolkata | UTC | 16,068 |
| Asia/Dubai | UTC | 16,004 |
| Asia/Dubai | Asia/Kolkata | 14,015 |
| UTC | Asia/Kolkata | 13,991 |

The vendor master was therefore treated as the more reliable source for vendor-level timezone mapping.

### 4. Vendor Mapping

The vendor master contains 15 vendor IDs across 5 vendor names.

The same vendor name can have multiple vendor IDs, vendor accounts, timezones, and schema versions.

Examples include Airtel, Twilio, Knowlarity, TataTele, and Exotel having multiple configurations.

Monthly vendor usage from January to July 2026 remained broadly consistent, so no major sudden vendor replacement was identified from call volumes.

### 5. Agent Identity

The agents table contains:

- 30,000 agent records
- 1,000 unique agent IDs
- 10 unique agent names

Each agent name is associated with a large number of agent IDs.

For example:
- Sneha Das: 958 agent IDs
- Priya Mehta: 957 agent IDs
- Amit Kumar: 952 agent IDs
- Vikram Shah: 936 agent IDs

This shows that agent name should not be used as a unique identity key.

### 6. Portfolio Mix

Monthly portfolio mix was checked using loan type and risk segment.

The monthly mix remained broadly stable, with no major structural shift identified in the analysed period.

### 7. Denominator and Recovery Rate

Monthly targeting volume was checked using the daily targeting table.

For January to July 2026, targeted accounts remained broadly stable between approximately 5,700 and 6,400 per month.

Recovery rate based on targeted accounts was:

| Month | Targeted Accounts | Paid Accounts | Recovery Rate |
|---|---:|---:|---:|
| Jan | 6,369 | 2,374 | 37.27% |
| Feb | 5,709 | 2,173 | 38.06% |
| Mar | 6,290 | 2,419 | 38.46% |
| Apr | 6,205 | 2,304 | 37.13% |
| May | 6,442 | 2,344 | 36.39% |
| Jun | 6,154 | 2,286 | 37.15% |
| Jul | 6,230 | 2,335 | 37.48% |

No clear evidence of denominator manipulation was found from the monthly targeting volumes and recovery rates.

## 11% Month-on-Month Recovery Claim

Successful payment recovery was analysed month by month.

| Month | MoM Change |
|---|---:|
| Feb 2026 | -9.05% |
| Mar 2026 | +11.11% |
| Apr 2026 | -7.38% |
| May 2026 | +5.20% |
| Jun 2026 | -4.60% |
| Jul 2026 | +6.48% |
| Aug 2026 | -74.84%* |

\* August is a partial month and should not be directly compared with complete months.

The analysis does not support a consistent 11% month-on-month improvement. Only March 2026 showed approximately 11% month-on-month growth.

## Notebooks

- `01_data_exploration.ipynb` - Part 1: Data exploration and Golden Dataset preparation
- `02_data_forensics.ipynb` - Part 2: Data forensics and recovery investigation

## Current Status

- Part 1 - Golden Dataset: Complete
- Part 2 - Data Forensics: Complete
- Part 3 - Statistical Investigation: Not started
