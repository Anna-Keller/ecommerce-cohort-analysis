# E-Commerce Customer Cohort & Revenue Analysis

This project analyzes customer purchase behavior in an e-commerce business using SQL (Google BigQuery).
The goal is to understand retention, repurchase behavior, and revenue drivers, and to translate these
findings into actionable business insights.

The analysis was completed as a structured case study and covers data cleaning, cohort analysis,
and high-level business development perspectives.

---

## Project Scope & Questions
The analysis focuses on the following questions:

- How does customer retention evolve across acquisition cohorts?
- Are later cohorts performing worse, or is the effect driven by limited observation windows?
- How does the share of returning customers change over time?
- Which product categories and countries drive revenue growth?
- What strategic insights can be derived for CRM, retention, and market expansion?

---

## Tech Stack
- **SQL**: Google BigQuery (GoogleSQL)
- **Data Modeling**: analytics-ready denormalized tables
- **Visualization**: Tableau
- **Reporting**: PDF case study report

---

## Repository Structure
```text
sql/
  order_items_enriched.sql
  cohort_analysis.sql
  repurchase_rate.sql
  monthly_revenue.sql
  active_customers.sql
  revenue_by_prod_category.sql
  revenue_by_country.sql
report/
  E-Commerce Customer Analytics.pdf
visuals/
  Active Customers.png
  Category Revenue.png
  Cohort Retention Heatmap.png
  Monthly Revenue.png
  Repurchase Rate.png
  Revenue by Country.png
  Revenue by Country_Bonus.png
README.md
```
---

## How to Run the Queries

1. **Run `order_items_enriched.sql` first**  
   This query:
   - cleans and deduplicates the `orders` table  
   - normalizes timestamps and country fields  
   - unnests product lists  
   - joins product attributes from `products_data`  
   - creates the table `order_items_enriched`, which all other queries depend on

2. **All remaining queries can be executed in any order**.

3. **Environment setup**  
   Each SQL file begins with short instructions on how to replace dataset and table names
   if you want to run the queries in a different BigQuery environment.

---

## Query Overview

### Data Cleaning & Normalization
- `order_items_enriched.sql`

### Cohort Analysis
- `cohort_analysis.sql`
- `repurchase_rate.sql`

### Business Development & Revenue Analysis
- `monthly_revenue.sql`
- `active_customers.sql`
- `revenue_by_prod_category.sql`
- `revenue_by_country.sql`

---

## Key Insights (Summary)

- Customer retention within cohorts is stable over time; apparent declines in late cohorts
  are caused by limited follow-up periods rather than behavioral changes.
- Customer behavior improves significantly from mid-2020 onward, reflected in higher
  repurchase and retention rates.
- Returning customers grow strongly from late 2020, increasing overall customer lifetime value.
- Revenue is highly concentrated in the core market (Germany ~91%), with Austria as the
  only notable secondary market, indicating clear international expansion potential.

---

## Notes on Data Privacy
Raw transactional data is not included in this repository.
All analysis is demonstrated via SQL logic, aggregated outputs, and visualizations.

---

## Purpose
This project was created as a **portfolio case study** to demonstrate skills in:
- SQL-based data modeling and analysis
- cohort and retention analytics
- translating data into business-relevant insights
- communicating results via structured reports and dashboards
