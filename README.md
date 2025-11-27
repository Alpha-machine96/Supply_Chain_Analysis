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

**Description:** The dataset contains order, customer, product, and shipping information for a global supply chain operation from January, 2015 to January, 2018.

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

    Overall on-time delivery rate
    
    Shipping modes ranked by reliability
    
    Variance analysis to identify inconsistent carriers

2. **Temporal Trends**

    Monthly order volume and revenue trends
    
    Day-of-week patterns in order placement
    
    Order processing time (order date → ship date)

3. **Product Intelligence**

    Top 20 products by revenue and profit
    
    Category performance comparison
    
    Products with highest late delivery risk
    
    Inventory turnover insights

4. **Customer Segmentation**

    Revenue by customer segment (Consumer, Corporate, Home Office)
    
    Customer lifetime value analysis
    
5. **Geographic Performance**

    Sales and delivery performance by country/region
    
    Regional shipping mode preferences
    
    Geographic delivery time variations

6. **Advanced Analytics**
    
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

**Customer Insights**

- A majority of the top 30 customers are from the Puerto Rican territory 

- The consumer segment appeals to more custommers than any other segment. 

**Product Performance**

- The Golf Carts and Bags category has highest profit margin at 19.15%

- The Fishing category made total sales of $6,929,653 with a profit margin of 12.14%

- Ogio Golf Race Shoes has highest late delivery risk despite strong sales

**Operational Issues**

- Same day deliveries shows high variance (unreliable)

- The Central African region consistently experiences longer delivery times

_______________________________________________________________________________________________________________________________

## Recommendations

- Negotiate with or replace unreliable shipping carriers showing high late delivery rates

- Investigate the main causes of late deliveries for the First and Second Class shipping modes

- Conduct sales campaigns to boost sales for the top ten products that generate the most profit 

- Implement expedited processing for high-value customer segments

- Optimize inventory in regions with longest delivery times

- Discontinue discount schemes that are >20%

____________________________________________________________________________________________________________________________

## Acknowledgments

- Dataset provided by DataCo via Kaggle

- Inspired by real-world supply chain analytics challenges

- Built as a portfolio project to demonstrate SQL expertise
