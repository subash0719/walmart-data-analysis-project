-------------------------------------------------------------
-- Table & Schema Creation
-------------------------------------------------------------
create table walmart_sales
(
	invoice_id int primary key,
	branch varchar(25),
	city varchar(25),
	category varchar(50),
	unit_price decimal(7, 2),
	quantity int,
	date date,
	time time,
	payment_method varchar(25),
	rating decimal(7,2),
	profit_margin decimal(7,2),
	total decimal(7,2)
);	

select * from walmart_sales;

-------------------------------------------------------------
-- Business Problems
-------------------------------------------------------------
--1. Find the different payment methods, no of transactions and qty sold for each

select 
	payment_method,
	count(*) as total_transactions,
	sum(quantity) as quantity_sold
from
	walmart_sales
group by
	payment_method;

--2. Which category received the highest average rating in each branch
with cte as
(
select
	branch,
	category,
	avg(rating) as avg_rating,
	row_number() over(partition by branch order by avg(rating) desc) as rnk 
from
	walmart_sales
group by
	branch,
	category)
select
	branch,
	category,
	avg_rating as rating
from
	cte
where
	rnk = 1;

--3. Find the busiest day of the week for each brand based on the transaction volume

select branch, week_day, transaction_volume from
	(
select 
	branch,
	datepart(WEEKDAY, date) as week_day,
	count(*) as transaction_volume,
	row_number() over(partition by branch order by count(*) desc) as rnk
from 
	walmart_sales
group by
	branch,
	datepart(WEEKDAY, date)) a
where a.rnk = 1
 
-- 4. total quantity sold through each payment method

select 
	payment_method,
	sum(quantity) as total_quantity
from 
	walmart_sales
group by	
	payment_method
order by 
	total_quantity desc

-- 5. what are the avg, min,max rating for each category in each city

select
	city,
	category,
	avg(rating) avg_rating,
	min(rating) min_rating,
	max(rating) max_rating
from 
	walmart_sales
group by 
	city,
	category
order by
	city

-- 6. what is the total profit for each category ranked from higehst to lowest

select
	category,
	sum(total * profit_margin) as profit
from 
	walmart_sales
group by 
	category
order by
	profit desc

-- 7. what is the most frequently used payment method in each branch
select branch, payment_method, no_of_times_used from(
select 
	branch,
	payment_method,
	count(*) as no_of_times_used,
	row_number() over(partition by branch order by count(*) desc) rnk
from 
	walmart_sales
group by 
	branch,
	payment_method) a
where rnk = 1

-- 8. How many transactions occur in each shift(mrng, noon, evng)

select 
	sum(case when time between '06:00:00.0000000' AND '12:00:00.0000000' then 1 else 0 end) as morning,
	sum(case when time between '12:01:00.0000000' AND '18:00:00.0000000' then 1 else 0 end) as noon,
	sum(case when time between '18:01:00.0000000' AND '23:01:00.0000000' then 1 else 0 end) as night
from
	walmart_sales;
-- 9. Which branch experienced the largest decrease in the revenue compared to its previous year

with revenue_2023
as
(
select
	branch,
	sum(total) as revenue_23
from 
	walmart_sales
where
	year(date) = 2023
group by 
	branch
)
,
revenue_2022 as
(
select
	branch,
	sum(total) as revenue_22
from 
	walmart_sales
where
	year(date) = 2022
group by 
	branch
)
select
	top 10 revenue_2022.branch,
	revenue_22,
	revenue_23,
	round((revenue_22 - revenue_23)/revenue_22 * 100, 2) as revenue_change
from
	revenue_2022 
inner join 
	revenue_2023
on 
	revenue_2022.branch = revenue_2023.branch
order by 
	revenue_change desc

