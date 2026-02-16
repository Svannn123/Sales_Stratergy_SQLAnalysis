
# Goal
Derive a sales strategy for the vacuum company from raw customer and review data.


# Sales Strategy SQL Analysis/ Idea used 

This project analyzes customer purchase behavior to understand how income level affects satisfaction and how discount campaigns influence sales performance.

The dataset contains customer details, product reviews, prices, and discount periods.

## Objective

Identify customer segments and determine an effective sales strategy using SQL-based analysis.


## Analysis Steps

1. Checked product ratings across professions
   - Observed that higher income professions consistently gave higher ratings

2. Created customer segments
   - Premium (Engineer, Manager, Doctor)
   - Mid (Nurse, Teacher, Artist)
   - Low (Jobless)

3. Measured impact of discount campaigns
   - Compared sales during Winter Sale and Summer Sale with normal sales baseline

4. Analyzed color preferences per segment

##  Findings

- Satisfaction strongly correlates with income level
- Summer sale significantly increases Premium segment sales (+54%) and slightly Mid (+11%)
- Winter sale decreases purchases in Premium and Mid segments
- Low income segment shows almost no response to discounts
- Red and Blue products are consistently preferred

## Files

- `sql/analysis.sql` → All queries used in analysis
- `results/insights.md` → Final interpretation and strategy
- CSV files → Input dataset

## Note
Customer name is used as a join key because this is a simplified dataset.  
In real systems a unique customer_id would be used.


## Approach

My reasoning process:
1. First checked if customer satisfaction differed across professions
2. Observed rating differences correlated with income level
3. Created customer segments (Premium / Mid / Low) to simplify analysis
4. Measured effect of discount campaigns using a daily-sales baseline comparison
5. Explored product preferences (color) within each segment

The goal was not only to compute metrics but to translate them into actionable business decisions.

