create table bmw(
	year numeric,
	month numeric,
	region varchar(50),
	model varchar(50),
	units_sold numeric,
	avg_price_EUR numeric,
	revenue_EUR numeric,
	bev_share numeric,
	premium_share numeric,
	gdp_growth numeric,
	fuel_price_index numeric
);


-- Display all records from the BMW sales dataset.

select * from bmw;

-- Show only the Year, Month, Region, Model, Units_Sold columns.

select year, month, region, model, units_sold from bmw;

-- List all distinct regions where BMW sold cars.

select distinct region from bmw;

-- Find all records where Units_Sold > 500.

select * from bmw
where units_sold > 500;

-- Retrieve data for Year = 2022.

select * from bmw
where year = 2022;

-- Show sales data only for the Europe region.

select * from bmw
where region = 'Europe';

-- List all distinct BMW models in the dataset.

select distinct model from bmw;

-- Show records where Fuel_Price_Index > 1.2.

select * from bmw
where fuel_price_index > 1.2;

-- Sort the dataset by Units_Sold in descending order.

select * from bmw
order by units_sold desc;

-- Retrieve the top 10 rows with highest Revenue_EUR.

select * from bmw
order by revenue_eur desc
limit 10;

-- Calculate the total Units Sold per Region.

select region, sum(units_sold) as total_units_sold from bmw
group by region;

-- Find the total Revenue generated per Year.

select year, sum(revenue_eur) as total_revenue from bmw
group by year
order by year;

-- Calculate the average price of cars per model.

select model, round(avg(avg_price_eur),2) as avg_price from bmw
group by model;

-- Find the maximum Units_Sold in a single record.

select * from bmw
where units_sold = (select max(units_sold) from bmw);

select * from bmw
order by units_sold desc
limit 1;

-- Calculate average GDP_Growth per region.

select region, round(avg(gdp_growth),2) as avg_gdp_growth from bmw
group by region;

-- Find total revenue generated per month.

select month, sum(revenue_eur) as total_revenue from bmw
group by month
order by month;

-- Show total units sold for each BMW model.

select model, sum(units_sold) as units_sold from bmw
group by model;

-- Calculate average Fuel_Price_Index by year.

select year, round(avg(fuel_price_index),2) as avg_fuel_price_index from bmw
group by year
order by year;

-- Find the total number of records per region.

select region, count(*) from bmw
group by region;

-- Calculate total revenue per region per year.

select region, year, sum(revenue_eur) as total_revenue from bmw
group by region, year
order by region, year;

-- Find total Units_Sold per Region per Year.

select region, year, sum(units_sold) as units_sold from bmw
group by region, year
order by region, year;

-- Show average price of each model in each region.

select region, model, round(avg(avg_price_eur),2) as avg_price from bmw
group by region, model
order by region, model;

-- Find regions where total revenue exceeded 1 million EUR.

select region, sum(revenue_eur) as total_revenue from bmw
group by region
having sum(revenue_eur) > 1000000;

-- Display models that sold more than 10,000 units in total.

select model, sum(units_sold) as total_units_sold from bmw
group by model
having sum(units_sold) > 10000;

-- Calculate average BEV share per region.

select region, round(avg(bev_share),2) as avg_bvg_share from bmw
group by region;

-- Find the top selling model in each region.

with bmw1 as
(select region, model, sum(units_sold) as total_units_sold,
rank() over(partition by region order by sum(units_sold) desc) as rnk from bmw
group by region, model)
select region, model, total_units_sold from bmw1
where rnk = 1;

select region, model, total_sales from 
(select region,model, sum(units_sold) as total_sales,
rank() over (partition by region order by sum(units_sold)desc)as rnk from bmw
group by region , model)
where rnk = 1;

-- Show total revenue generated per model per year.

select model, year, sum(revenue_eur) as total_revenue from bmw
group by model, year
order by model, year;

-- Find regions with average GDP growth greater than 3%.

select region, round(avg(gdp_growth),2) as avg_gdp_growth from bmw
group by region
having avg(gdp_growth) > 3;

-- Show monthly revenue trend for Europe.

select region, year, month, sum(revenue_eur) as monthly_revenue from bmw
where region = 'Europe'
group by region, year, month
order by year, month;

-- Calculate average premium share per year.

select year, round(avg(premium_share),2) as avg_premium_share from bmw
group by year
order by year;

-- Rank models by Units_Sold within each region.

select region, model, sum(units_sold),
rank() over(partition by region order by sum(units_sold) desc)
from bmw
group by region, model;

-- Calculate running total of revenue by year.

select year, revenue,
sum(revenue) over(order by year)
from (select year, sum(revenue_eur) as revenue
from bmw group by year);

-- Find the top 3 selling models in each region.

with bmw1 as
(select region, model, sum(units_sold) as total_units_sold,
rank() over(partition by region order by sum(units_sold) desc) as rnk from bmw
group by region, model)
select region, model, total_units_sold from bmw1
where rnk in (1, 2, 3);

-- Calculate month-over-month revenue change.

select year, month, sum(revenue_eur) as total_revenue,
lag(sum(revenue_eur)) over(order by year, month) as previous_month_revenue,
sum(revenue_eur) - lag(sum(revenue_eur)) over(order by year, month) as revenue_change
from bmw
group by year, month
order by year, month;

-- Assign dense rank for models based on total units sold.

select model, sum(units_sold) as total_units_sold,
dense_rank() over(order by sum(units_sold) desc) as rank
from bmw
group by model;

-- Calculate cumulative units sold per region.

SELECT region, year, month, model, sum(units_sold),
SUM(SUM(units_sold)) OVER (PARTITION BY region ORDER BY year, month) AS cumulative_units_sold
FROM bmw
group by region, year, month, model 
ORDER BY region, year, month, model;

-- Find the highest revenue month per year.

select year, month, total_revenue from
(select year, month, sum(revenue_eur) as total_revenue,
rank() over(partition by year order by sum(revenue_eur) desc) as rnk
from bmw
group by year, month)
where rnk = 1;

-- Compare each model’s revenue with the regional average revenue.

select region, regional_avg_revenue, model, model_revenue, 
regional_avg_revenue - model_revenue as difference from
(select region, model, sum(revenue_eur) as model_revenue,
round(avg(sum(revenue_eur)) over(partition by region),0) as regional_avg_revenue
from bmw
group by region, model);

-- Calculate percentage contribution of each model to region sales.

select region, model, round(model_sales_revenue * 100 / regional_sales_revenue,2) as regional_percentge_contribution from
(select region, sum(sum(revenue_eur)) over(partition by region) as regional_sales_revenue,
model, sum(revenue_eur) as model_sales_revenue from bmw
group by region, model)

-- Find previous month's revenue using LAG().

select year, month, sum(revenue_eur) as monthly_revenue,
lag(sum(revenue_eur)) over(order by year, month) as previous_month_revenue
from bmw
group by year, month
order by year, month;

-- Which region generated the highest revenue overall?

select region, sum(revenue_eur) as total_revenue
from bmw
group by region
order by sum(revenue_eur) desc
limit 1;

-- Which BMW model generated the most revenue?

select model, sum(revenue_eur) as model_revenue
from bmw
group by model
order by sum(revenue_eur) desc
limit 1;

-- What is the yearly growth rate of BMW sales?

select year, total_revenue, previous_year_revenue,
round((total_revenue-previous_year_revenue)*100/previous_year_revenue,2) as yearly_growth_rate from
(select year, sum(revenue_eur) as total_revenue,
lag(sum(revenue_eur)) over(order by year) as previous_year_revenue
from bmw group by year);

-- Which region has the highest BEV (electric vehicle) share?

select region, round(avg(bev_share),4) as avg_bev_share from bmw
group by region
order by avg(bev_share) desc
limit 1;

-- Which month historically has the highest sales?

select year, month, sum(units_sold) as highest_sales, sum(revenue_eur) as highest_revenue from bmw
group by year, month
order by sum(revenue_eur) desc
limit 1;

-- What is the trend of electric vehicle adoption (BEV share) over years?

select year, round(avg(bev_share),4) as avg_bvg_share from bmw
group by year
order by year;

-- Which region has the highest premium share?

select region, round(avg(premium_share),2) from bmw
group by region
order by avg(premium_share) desc
limit 1;

-- Identify top performing region each year.

select year, region from
(select year, region, sum(revenue_eur),
rank() over(partition by year order by sum(revenue_eur) desc) as rnk
from bmw
group by year, region)
where rnk = 1;

-- Calculate Year-over-Year revenue growth.

select year, sum(revenue_eur) as total_revenue,
lag(sum(revenue_eur)) over(order by year) as previous_year_revenue,
round((sum(revenue_eur) - lag(sum(revenue_eur)) over(order by year)) * 100 / lag(sum(revenue_eur)) over(order by year),2) as yearly_revenue_growth from bmw
group by year
order by year;

-- Identify fastest growing BMW model.

with model_yearly_sales as
(select model, year, sum(units_sold) as total_units from bmw group by model, year),
growth_calc as
(select model, year, total_units, lag(total_units) over(partition by model order by year) as prev_year_units,
ROUND((total_units - lag(total_units) over(partition by model order by year)) * 100.0 /
lag(total_units) over(partition by model order by year),2) AS growth_percent
from model_yearly_sales)
select model, max(growth_percent) as max_growth_percent from growth_calc
group by model
order by max_growth_percent desc
limit 1;

-- Detect seasonal patterns in BMW sales.

select month, round(avg(units_sold), 2) as avg_units_sold from bmw
group by month
order by month;

-- Compare electric vehicle share vs total revenue growth.

with yearly_data as
(select year, round(avg(bev_share),4) as avg_bev_share, sum(revenue_eur) as total_revenue from bmw
group by year),
growth_calc as
(select year, avg_bev_share, total_revenue,
lag(total_revenue) over(order by year) as prev_revenue,
round((total_revenue - lag(total_revenue) over(order by year)) * 100.0 /
lag(total_revenue) over(order by year),2) as revenue_growth_percent from yearly_data)
select * from growth_calc
order by year;

-- Calculate revenue per unit sold by model.

with bmw_sales as (select model, sum(revenue_eur) as total_revenue, sum(units_sold) as total_units_sold
from bmw group by model)
select model, round(total_revenue/total_units_sold,0) as revenue_per_unit from bmw_sales;

-- Find months where revenue dropped compared to previous month.

with xyz as
(select year, month, sum(revenue_eur) as monthly_revenue,
lag(sum(revenue_eur)) over(order by year, month) as prev_month_revenue,
sum(revenue_eur) - lag(sum(revenue_eur)) over(order by year, month) as revenue_growth
from bmw group by year, month order by year, month)
select year, month, monthly_revenue, prev_month_revenue, revenue_growth from xyz
where revenue_growth < 0;
