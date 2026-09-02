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

### 2.1. Duplicate Payments

The raw payments table contains duplicate payment records.

- 972 rows are involved in duplicate payment groups.
- 486 extra rows remain after keeping one copy of each exact duplicate.
- Duplicate rows represent approximately 1.95% of the total raw payment amount.

The duplicate records include SUCCESS, FAILED, PENDING, and REVERSED payment statuses.

### 2.2. Payment Attribution

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

### 2.3. Timezone Problems

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

### 2.4. Vendor Mapping

The vendor master contains 15 vendor IDs across 5 vendor names.

The same vendor name can have multiple vendor IDs, vendor accounts, timezones, and schema versions.

Examples include Airtel, Twilio, Knowlarity, TataTele, and Exotel having multiple configurations.

Monthly vendor usage from January to July 2026 remained broadly consistent, so no major sudden vendor replacement was identified from call volumes.

### 2.5. Agent Identity

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

### 2.6. Portfolio Mix

Monthly portfolio mix was checked using loan type and risk segment.

The monthly mix remained broadly stable, with no major structural shift identified in the analysed period.

### 2.7. Denominator and Recovery Rate

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

## Part 3 – Statistical Investigation

The objective of Part 3 was to determine whether observed recovery changes were driven by operational improvements or by changes in the underlying population.

### 3.1 Mix Effects

Recovery rates were compared across risk segments.

| Risk Segment | Total Accounts | Paid Accounts | Recovery Rate |
|---|---:|---:|---:|
| HIGH | 7,552 | 3,300 | 43.70% |
| LOW | 7,513 | 3,381 | 45.00% |
| MEDIUM | 7,533 | 3,335 | 44.27% |
| NPA | 7,402 | 3,268 | 44.15% |

Recovery rates were close across risk segments, ranging from 43.70% to 45.00%. No major mix effect was observed.

### 3.2 Cohort Effects

Accounts were grouped by their opening month and recovery was measured using successful payment history.

Cohort recovery rates ranged approximately from 41.63% to 46.90%, with no clear upward trend across cohorts.

This analysis suggests that cohort composition alone does not explain the claimed 11% month-on-month improvement.

### 3.3 Selection Bias

Targeted and non-targeted accounts were compared.

| Group | Total Accounts | Paid Accounts | Recovery Rate |
|---|---:|---:|---:|
| Non-targeted | 6,656 | 2,996 | 45.01% |
| Targeted | 23,344 | 10,288 | 44.07% |

Targeted accounts had a recovery rate 0.94 percentage points lower than non-targeted accounts.

This indicates a small selection effect, but it is not large enough by itself to explain an 11% improvement.

### 3.4 Survivorship Bias

Final account status was examined to identify whether different account outcomes could materially affect the recovery result.

| Final Status | Recovery Rate |
|---|---:|
| ACTIVE | 45.07% |
| CLOSED | 44.08% |
| DELINQUENT | 43.94% |
| NPA | 42.65% |
| PAID | 44.97% |
| PTP | 44.67% |
| WRITEOFF | 44.89% |

Recovery rates varied by final status, with a maximum difference of approximately 2.42 percentage points.

The variation indicates some population effect, but it does not appear large enough to explain an 11% month-on-month improvement.

### 3.5 Simpson's Paradox

Recovery was compared across months and risk segments.

Risk-segment recovery rates varied across months, but the subgroup results did not show a consistent reversal of the overall trend.

Therefore, no clear evidence of Simpson's paradox was identified from the available analysis.

### 3.6 Attribution-Window Bias

The effect of different attribution windows was examined.

| Attribution Window | Attributed Payments |
|---|---:|
| 7 days | 8.94% |
| 14 days | 16.64% |
| 30 days | 31.45% |
| 60 days | 49.67% |

Attribution is highly sensitive to the selected time window. Only 8.94% of payments were attributed within 7 days, compared with 49.67% within 60 days.

Therefore, short attribution windows can materially understate campaign impact.

### 3.7 Time-Series Effects

Monthly successful recovery amount was analyzed to identify a sustained month-on-month improvement.

| Month | Recovery Amount | MoM Change |
|---|---:|---:|
| Jan 2026 | ₹18.72 Cr | — |
| Feb 2026 | ₹17.03 Cr | -9.05% |
| Mar 2026 | ₹18.92 Cr | +11.11% |
| Apr 2026 | ₹17.52 Cr | -7.38% |
| May 2026 | ₹18.43 Cr | +5.20% |
| Jun 2026 | ₹17.59 Cr | -4.60% |
| Jul 2026 | ₹18.72 Cr | +6.48% |

August was excluded from the trend interpretation because it is a partial month.

The time-series does not show a sustained 11% month-on-month improvement. The approximately 11% increase occurred only in March 2026.

### Part 3 Conclusion

The statistical investigation does not support a consistent 11% month-on-month recovery improvement.

Mix, cohort, selection and survivorship effects exist to some extent, while no clear Simpson's paradox was identified. Attribution results are highly sensitive to the attribution window, and the monthly recovery trend is inconsistent.

Overall, the observed data suggests that the reported 11% improvement should not be treated as a sustained operational improvement without further validation.

## Part 4 – Counterfactual Analysis and Investment Recommendation

The objective of Part 4 was to evaluate whether the observed recovery after the assumed mid-year strategy change was better than the expected recovery under the pre-change baseline.

### 4.1 Strategy Change Assessment

The daily targeting data was analysed for changes in campaign, channel, priority, and targeting status mix.

Key findings:

- 120 unique campaigns were present in each analysed month.
- Channel shares remained broadly stable at approximately 24–26% per channel.
- Priority distribution remained broadly stable across months.
- Targeting status distribution remained broadly stable at approximately 24–26% per status.

No clear structural break in the targeting strategy was identified from these variables.

For the counterfactual analysis, January–June 2026 was treated as the pre-change baseline period and July–August 2026 as the post-change period.

### 4.2 Pre-Change Baseline

Recovery per targeted account was calculated for January–June 2026.

The average pre-change recovery was:

**₹32,330.38 per targeted account**

This value was used as the counterfactual baseline.

### 4.3 July Counterfactual

July 2026 was compared against the pre-change baseline.

| Metric | July 2026 |
|---|---:|
| Targeted Accounts | 5,666 |
| Actual Recovery | ₹18.72 Cr |
| Expected Recovery | ₹18.32 Cr |
| Difference | +₹40.64 Lakh |
| Change vs Counterfactual | +2.22% |

July recovery was approximately 2.22% above the expected recovery based on the pre-change baseline.

This is substantially lower than the claimed 11% improvement.

### 4.4 August Counterfactual

August was also compared with the same baseline.

| Metric | August 2026 |
|---|---:|
| Targeted Accounts | 1,566 |
| Actual Recovery | ₹4.71 Cr |
| Expected Recovery | ₹5.06 Cr |
| Difference | -₹35.20 Lakh |
| Change vs Counterfactual | -6.95% |

August was below the counterfactual baseline. However, August is a partial month, so this result should be treated as indicative rather than a definitive measure of strategy performance.

### 4.5 Channel Analysis

Observed payment timing was compared across the four collection channels.

| Channel | Payments After Interaction | Average Days to Payment | Median Days to Payment |
|---|---:|---:|---:|
| VOICE | 11,933 | 43.95 | 33.13 |
| WHATSAPP | 9,994 | 52.08 | 40.65 |
| SMS | 8,428 | 56.14 | 44.65 |
| FIELD | 5,604 | 62.96 | 52.07 |

Voice had the shortest observed time-to-payment among the four channels.

A simple speed score was calculated using Voice as the reference channel:

| Channel | Speed Score |
|---|---:|
| VOICE | 100.00 |
| WHATSAPP | 84.39 |
| SMS | 78.29 |
| FIELD | 69.81 |

The channel analysis is descriptive and does not establish causal impact because borrower risk, targeting priority, campaign selection, and other confounding factors were not controlled.

### 4.6 ₹10 Cr Investment Recommendation

Based on the available evidence, Voice should be prioritised as the primary channel for a controlled investment pilot because it has the fastest observed time-to-payment.

However, the analysis does not provide sufficient evidence to allocate the full ₹10 Cr directly to Voice.

Recommended approach:

1. Prioritise Voice for an initial controlled pilot.
2. Maintain a holdout/control group to measure incremental recovery.
3. Compare recovery against the pre-change baseline.
4. Measure incremental recovery, cost per recovered rupee, and ROI.
5. Scale investment only if the pilot demonstrates statistically and economically meaningful incremental recovery.

### Part 4 Conclusion

The counterfactual analysis does not support the reported 11% improvement as a sustained operational gain.

July showed only a **2.22% uplift** versus the pre-change baseline, while August showed a **6.95% shortfall**, although August is a partial month.

Channel-level analysis indicates that **Voice has the fastest observed payment timing**, making it the strongest candidate for further investment testing.

Therefore, the recommended decision is to **pilot investment in Voice with a controlled holdout rather than immediately deploying the full ₹10 Cr**.

## Data Quality Report

The Data Quality Report documents the major data quality issues identified
during the analysis and their potential business impact.

Key issues investigated include:

- Exact duplicate records
- Duplicate payment records
- Missing values
- Timezone inconsistencies
- Agent identity inconsistencies
- Payment attribution-window sensitivity

The report documents the detection methodology, treatment applied, business
impact, and recommended production controls for each issue.

The detailed report is available in:

- `06_data_quality_report.ipynb`

## Part 5 – Production Analytics Architecture

A production-ready analytics architecture was designed using the following flow:

**Raw → Staging → Clean → Golden → Feature → Metrics → Dashboard**

### Architecture Layers

- **Raw:** Stores source data as received from operational systems.
- **Staging:** Standardizes schemas, column names, data types, timestamps, and source identifiers.
- **Clean:** Applies deduplication, validation, entity resolution, and cleaning rules.
- **Golden:** Stores trusted datasets used as the analytical source of truth.
- **Feature:** Creates analytical features for customer, account, agent, campaign, and payment analysis.
- **Metrics:** Calculates approved business metrics such as recovery amount, recovery rate, and conversion.
- **Dashboard:** Presents standardized metrics and trends for business and leadership decisions.

### Data Contracts

The production design defines primary keys and important fields for each analytical
table. Data contracts should enforce uniqueness, required fields, valid foreign keys,
consistent timestamps, valid monetary amounts, approved status codes, and versioned
schema changes.

### Data Quality and Monitoring

Automated checks should monitor:

- Primary key uniqueness and null values
- Foreign key validity
- Duplicate records
- Missing values
- Timestamp and timezone consistency
- Payment amount validity
- Status and disposition values
- Daily row-count anomalies
- Recovery-rate anomalies
- Campaign and channel mix changes
- Pipeline failures and delayed data

### Incremental Processing

The pipeline should use event and ingestion timestamps with source-specific
watermarks. An overlap window should be used to capture late-arriving records.
Affected historical periods should be reprocessed when corrections are received.

### Late-Arriving Data and Backfills

Late-arriving records should be loaded according to their event date and affected
downstream data should be recalculated. Backfills should identify the affected
period, reprocess the required data, validate the results, and record the reason
and execution details.

### Data Lineage

The expected lineage is:

**Source Systems → Raw → Staging → Clean → Golden → Feature → Metrics → Dashboard**

Lineage should record source tables, transformations, key relationships, data-quality
checks, metric logic, processing timestamps, and backfill activity.

### Standard Metric Definitions

- **Recovery Amount:** Sum of successful payment amounts for the selected period.
- **Successful Payments:** Count of payment records with `payment_status = SUCCESS`.
- **Paying Accounts:** Number of unique accounts with at least one successful payment.
- **Recovery Rate:** Paying accounts divided by the defined eligible account population.
- **Payment Conversion:** Accounts with a successful payment divided by the defined contacted or targeted population.
- **MoM Recovery Growth:** Percentage change in recovery amount compared with the previous month.
- **Average Payment Amount:** Total successful recovery amount divided by successful payments.

### Conclusion

The proposed architecture creates a controlled and traceable path from operational
data to business reporting. It addresses data quality, deduplication, schema changes,
timestamp handling, late-arriving data, backfills, metric consistency, lineage, and
monitoring.

The Golden Dataset remains the source of truth for analytical reporting, while the
Metrics layer provides standardized business KPIs.

## SQL Repository

Production-quality SQL queries covering data cleaning, transformations,
metric calculations, and analytical queries.

The SQL repository is organized into four files:

- `sql/01_data_cleaning.sql` - Data cleaning and validation queries
- `sql/02_transformations.sql` - Analytical data transformations
- `sql/03_metric_calculations.sql` - Standard business metric calculations
- `sql/04_analytical_queries.sql` - Recovery, risk, campaign, channel, agent, vendor, and payment analysis

The SQL queries are designed to be reproducible and aligned with the Golden
Dataset and the business questions investigated in this assignment.

## Notebooks

- `01_data_exploration.ipynb` - Part 1: Data exploration and Golden Dataset preparation
- `02_data_forensics.ipynb` - Part 2: Data forensics and recovery investigation
- `03_statistical_investigation.ipynb` - Part 3: Statistical investigation of recovery performance
- `04_counterfactual_analysis.ipynb` - Part 4: Counterfactual analysis and ₹10 Cr investment recommendation
- `05_production_analytics_architecture.ipynb` - Part 5: Production analytics architecture
