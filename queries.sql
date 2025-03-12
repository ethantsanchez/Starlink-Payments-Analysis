-- Project name: Starlink-Inspired Telemetry Analysis

-- Dataset used: "fraudTrain.csv" from 
--  the Credit Card Transactions Fraud Detection Dataset by Kartik Shenoy,
--  who generated the data using the Sparkov Data Generation | Github tool by Brandon Harris
--  (source: Kaggle, https://www.kaggle.com/datasets/kartik2112/fraud-detection/data?select=fraudTrain.csv ).

-- Project by Ethan Troy Sanchez

-- EXPLORATORY SECTION:

SELECT COUNT(*) AS Total 
FROM transactions;
-- The output is Total = 1296675 .

SELECT is_fraud, COUNT(*) AS FraudCount
FROM transactions
GROUP BY is_fraud; -- '0' is legitimate, '1' is fraud
-- The output is
--  is_fraud == 0, FraudCount = 1289169
--  is_fraud == 1, FraudCount = 7506 .

SELECT ( COUNT(*)
	FILTER (WHERE is_fraud = 0) * 1.0 / COUNT(*)  ) * 100 AS SuccessRate
FROM transactions;
-- The output is SuccessRate = 99.4211348256117 ,
-- a 99.42 percent success rate.

SELECT ( COUNT(*)
	FILTER (WHERE is_fraud = 1) * 1.0 / COUNT(*) ) * 100 AS FraudRate
FROM transactions;
-- The output is FraudRate = 0.578865174388339 ,
-- a 0.58 percent fraudulent rate

-- This is the baseline fraud rate. High conversion, low fraud:
-- a 0.58% fraud rate is equivalent to 7506 fraudulent transactions (txns).

-- ANALYSIS SECTION:

-- Metric #1: success rate by category
SELECT category,
	COUNT(*) AS Txns,
	SUM( CASE
		WHEN is_fraud = 0 THEN 1
		ELSE 0 
		END ) AS Legit,
	( SUM( CASE
		WHEN is_fraud = 0 THEN 1
		ELSE 0 
		END ) * 1.0 / COUNT(*) ) * 100 AS SuccessRateByCategory
FROM transactions
GROUP BY category
ORDER BY SuccessRateByCategory;
-- category mimics how Starlink's payment methods vary.
-- For category, shopping_net is 98.2% successful,
--							  misc_net is 98.55% successful,
--							  grocery_pos is 98.59% successful, etc.
-- Starlink's payment methods vary too, like credit, PayPal, etc.
-- The lower success rates are the optimization targets, the areas to pay attention to.
-- The output is saved as "success_by_category.csv".

-- Metric #2: fraud costs by state
SELECT state,
	SUM( CASE
		WHEN is_fraud = 1 THEN amt
		ELSE 0
		END ) AS FraudCost,
	COUNT( CASE
		WHEN is_fraud = 1 THEN 1
		END ) AS FraudCount
FROM transactions
GROUP BY state
ORDER BY FraudCost DESC;
-- This query (especially by ordering in descending order)
--  highlights where the regional fraud spikes are,
--  which, in the case of Starlink, could tank its costs
--  if responded to accordingly.
-- This would be similar to handling multi-processor issues.
-- This query emphasizes the fraud cost per state
--  to mimic processor losses.
-- For example, with this descending order via FraudCost,
--  the output shows that the top 5 states with the highest fraud counts
--  and fraud costs are:
--   New York (NY), with 555 frauds totaling to $295,548.64
--   Texas (TX), with 479 frauds totaling to $265,806.41
--   Pennsylvania (PA), with 458 frauds totaling to $244,624.67
--   California (CA), with 326 frauds totaling to $170,943.92
--   Ohio (OH), with 321 frauds totaling to $168,919.98 .
-- For SpaceX, these would constitute Starlink wins,
--  as cutting fraud in significant high-cost states like CA and TX with tighter checks
--  would likely increase the future success rates set up in Metric #1.
-- The output is saved as "fraud_by_state.csv".

-- Metric #3: Average Amount by Outcome
SELECT is_fraud,
	AVG(amt) AS AvgAmount,
	COUNT(*) AS Txns
FROM transactions
GROUP BY is_fraud;
-- This query shows that fraud transactions, on average, are more expensive,
--  providing a clue for where to implement cost reduction.
-- This kind of query could be written for a similar situation in SpaceX.
-- The output is saved as "amount_by_outcome.csv".

-- Metric #4: Time Trend
SELECT strftime('%Y-%m-%d', trans_date_trans_time) AS Date,
	COUNT(*) AS Txns,
	SUM(is_fraud) AS Frauds
FROM transactions
GROUP BY Date;
-- This query records the number of transactions and number of frauds
--  per day, from January 1, 2019, to June 21, 2020.
-- This output, saved as "time_trend.csv", can be visualized
--  with time-series data, dashboards, or some other type of sequential tool
--  to show change and potential patterns over time.
