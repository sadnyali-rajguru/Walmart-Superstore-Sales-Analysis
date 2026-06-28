
-- Q.1) Which Region Has The Highest Total Sales And Profit?
select region,
sum(sales) as total_sales,
sum(profit) as total_profit
from superstore_data
group by region
order by total_Sales desc;

-- Q2) Which States Are Generating Losses For The Business?
select state,
sum(profit) as total_profit
from superstore_data
group by state
having sum(profit)<0
order by total_profit;

-- Q3) Which Customer Segment Contributes The Highest Profit?
select segment,
sum(profit) as total_profit
from superstore_data
group by segment
order by total_profit desc;

-- Q4) Which Sub-categories Are Loss-making Despite Generating Good Sales?
select sub_category,
sum(Sales) as total_Sales,
sum(profit) as total_profit
from superstore_data
group by sub_category
having sum(profit)<0
order by total_profit;

-- Q5) Which Products Have Sales Higher Than Average Product Sales?
WITH product_sales AS (
    SELECT product_name,
           SUM(sales) AS total_sales
    FROM superstore_data
    GROUP BY product_name
)
SELECT product_name,
       total_sales
FROM product_sales
WHERE total_sales >
      (SELECT AVG(total_sales) FROM product_sales);

-- Q6) Classify Customers By Order Frequency?
select customer_name,
count(order_id) as total_orders,
   case
     when count(order_id)>=15 then 'frequent buyer'
     when count(order_id)>=5 then 'moderate buyer'
   else 'occasional buyer'
 end as customer_type
from superstore_data
group by customer_name;

-- Q7) Which Is The Top Selling Product In Each Category?
with cte as(
	select category,product_name,
    sum(Sales) as total_Sales,
    row_number() over(partition by category order by sum(sales) desc) as rn
    from superstore_data
    group by category,product_name
    )
    select category,product_name,total_Sales
    from cte
    where rn=1;

-- Q8) Which Regions Perform Above Average Regional Profit?
with region_profit as(
    select region,sum(profit) as total_profit
    from superstore_data
    group by region
    )
    select region,total_profit
    from region_profit
    where total_profit>(select avg(total_profit) from region_profit);

-- Q9) What Is The Year-over-year Sales Trend?
WITH yearly_sales AS (
    SELECT YEAR(order_date) AS order_year,
           SUM(sales) AS total_sales
    FROM superstore_data
    GROUP BY YEAR(order_date)
)
SELECT
    order_year,
    total_sales,
    LAG(total_sales) OVER(ORDER BY order_year) AS previous_year_sales,
    total_sales -
    LAG(total_sales) OVER(ORDER BY order_year) AS sales_growth
FROM yearly_sales;

-- Q10) Which Customer In Each Region Genrates The Highest Profit?
with cte as(
   select region,customer_name,
   sum(profit) as total_profit,
   row_number()over(partition by region order by sum(profit) desc) as rn
   from superstore_data
   group by region,customer_name
   )
   select region,customer_name,total_profit
   from cte
   where rn=1;