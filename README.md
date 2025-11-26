# Supply Chain Analysis
___________________________________________________________________________________________________________________________________________

##  Project Overview
This project analyzes supply chain and logistics data from DataCo, a global e-commerce company, to identify delivery performance issues, optimize 
shipping operations, and uncover insights for improving customer satisfaction. The analysis uses PostgreSQL to demonstrate advanced SQL skills including data normalization, complex JOINs, window functions, and business intelligence queries.
_______________________________________________________________________________________________________________________________________

##  Business Objectives

Identify delivery bottlenecks and shipping modes with highest late delivery rates

Analyze customer behavior across different segments and regions

Optimize product inventory by identifying high-performing and problematic products

Measure profitability and the impact of discounts on margins

Detect patterns in order processing and fulfillment times
________________________________________________________________________________________________________________________________________

##  Dataset

**Source:** DataCo SMART SUPPLY CHAIN Dataset on Kaggle

**Description:** The dataset contains order, customer, product, and shipping information for a global supply chain operation.

**Key Features:**

Order details (dates, status, regions)

Customer information (segments, locations)

Product catalog (categories, prices, profitability)

Shipping data (modes, delivery times, late delivery risk)

Sales and discount information
____________________________________________________________________________________________________________________________________

##  Database Design

Entity-Relationship Structure

The project normalizes the raw CSV data into 5 relational tables:

**customers** - Customer demographic and location data

**products** - Product catalog with categories and pricing

**orders** - Order header information

**order_items** - Line-item details for each order

**shipments** - Shipping and delivery performance data
_____________________________________________________________________________________________________________________________________________
##  Technologies Used

Database: PostgreSQL 18

SQL Concepts:


Data normalization and foreign key relationships

Complex multi-table JOINs

Window functions (RANK, LAG, LEAD, running totals)

Common Table Expressions (CTEs)

Aggregate functions and GROUP BY

Date/time calculations

CASE statements for categorization
_________________________________________________________________________________________________________________________________________
## Key Analyses

1. **Delivery Performance Analysis**

    Overall on-time delivery rate: XX%
    
    Shipping modes ranked by reliability
    
    Variance analysis to identify inconsistent carriers

2. **Temporal Trends**

    Monthly order volume and revenue trends
    
    Day-of-week patterns in order placement
    
    Order processing time (order date → ship date)
    
    Seasonal patterns in late deliveries

3. **Product Intelligence**

    Top 20 products by revenue and profit
    
    Category performance comparison
    
    Products with highest late delivery risk
    
    Inventory turnover insights

4. **Customer Segmentation**

    Revenue by customer segment (Consumer, Corporate, Home Office)
    
    Customer lifetime value analysis
    
    Retention analysis (one-time vs. repeat customers)
    
    VIP customer identification

5. **Geographic Performance**

    Sales and delivery performance by country/region
    
    Regional shipping mode preferences
    
    Geographic delivery time variations

6. **Advanced Analytics**

    Cohort analysis: Monthly customer retention rates
    
    Window functions: Product ranking within categories, running totals
    
    Purchase patterns: Time between orders using LAG/LEAD
    
    Profitability: Impact of discount tiers on margins

7. **Problem Identification**

    Orders with significant delays (>5 days over schedule)
    
    High-value customers experiencing late deliveries
    
    Shipping modes needing improvement

___________________________________________________________________________________________________________________________________________
## Key Findings

**Delivery Performance**

- First Class has the highest late delivery rate at 95.27%

- Average delivery delay: 0.57 days beyond scheduled time

- XX% of late deliveries occur in [Region/Country]

**Customer Insights**

- [Segment] customers generate XX% of revenue but represent only XX% of customer base

- XX% of customers are one-time buyers (retention opportunity)

- Top 20 customers contribute XX% of total revenue

**Product Performance**

- Golf Carts and Bags has highest profit margin at 19.15%

- Ogio Golf Race Shoes has highest late delivery risk despite strong sales

- Discounts >20% reduce profit margins by XX% on average

**Operational Issues**

- [Shipping Mode] shows high variance (unreliable)

- Processing time increased by XX% during [Time Period]

- [Region] consistently experiences longer delivery times

_______________________________________________________________________________________________________________________________

## Recommendations

- Negotiate with or replace unreliable shipping carriers showing high late delivery rates

- Implement expedited processing for high-value customer segments

- Optimize inventory in regions with longest delivery times

- Review discount strategy for products with <X% profit margin

- Launch customer retention program targeting one-time buyers

- Investigate bottlenecks in [specific region/category] causing delays

____________________________________________________________________________________________________________________________

## Acknowledgments

- Dataset provided by DataCo via Kaggle

- Inspired by real-world supply chain analytics challenges

- Built as a portfolio project to demonstrate SQL expertise
