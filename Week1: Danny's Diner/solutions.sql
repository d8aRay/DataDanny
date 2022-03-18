/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
select sales.customer_id
	, sum(menu.price) 
from dannys_diner.sales as sales
	left join dannys_diner.menu as menu on sales.product_id = menu.product_id 
group by sales.customer_id 
;

-- 2. How many days has each customer visited the restaurant?
select sales.customer_id
	, count( distinct sales.order_date) as customer_visits
from dannys_diner.sales
group by 1
;

-- 3. What was the first item from the menu purchased by each customer?
with first_orders as( 
	select sales.customer_id
    	, min(sales.order_date) as first_order
    from dannys_diner.sales
    group by 1 )
select sales.customer_id
	, sales.product_id
from first_orders
	left join dannys_diner.sales on first_orders.customer_id = sales.customer_id
    							 and first_orders.first_order = sales.order_date
;                                 
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_id
	, count(product_id) item_sales
from dannys_diner.sales
group by 1
order by item_sales desc 
limit 1
; 


-- 5. Which item was the most popular for each customer?
with cust_item_sales as (
select customer_id
	, product_id
	, count(product_id) item_sales
from dannys_diner.sales
group by 1, 2), 
ranks as (
select customer_id
	, product_id 
	, dense_rank() over (partition by customer_id order by item_sales desc) as rank
from cust_item_sales) 
select customer_id
	, menu.product_name
from ranks 
	left join dannys_diner.menu on ranks.product_id = menu.product_id
where rank = 1
order by customer_id 
; 

-- 6. Which item was purchased first by the customer after they became a member?
with ranks as(
  	select sales.customer_id
		, sales.product_id
    	, dense_rank() over (partition by sales.customer_id order by sales.order_date) as rank
	from dannys_diner.sales 	
    	inner join dannys_diner.members on sales.customer_id = members.customer_id
    									and sales.order_date >= members.join_date
)
select customer_id  
	, product_name  
from ranks 
	left join dannys_diner.menu on ranks.product_id = menu.product_id 
where rank = 1
;   
-- 7. Which item was purchased just before the customer became a member?
with ranks as(
  	select sales.customer_id
		, sales.product_id
    	, dense_rank() over (partition by sales.customer_id order by sales.order_date) as rank
	from dannys_diner.sales 	
    	inner join dannys_diner.members on sales.customer_id = members.customer_id
    									and sales.order_date < members.join_date
)
select customer_id  
	, product_name  
from ranks 
	left join dannys_diner.menu on ranks.product_id = menu.product_id 
where rank = 1
; 

-- 8. What is the total items and amount spent for each member before they became a member?
select sales.customer_id
       , count(sales.product_id) as total_items 
       , sum(menu.price) as spend
from dannys_diner.sales
	left join dannys_diner.menu on menu.product_id = sales.product_id
	left join dannys_diner.members on sales.customer_id = members.customer_id
where sales.order_date < members.join_date
group by sales.customer_id
; 
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with allocate_points as (
  select product_id
  	, product_name
    , price 
 	, case when product_name = 'sushi' then price*20
  			else price*10
  			end as points
  from dannys_diner.menu
 )

select customer_id
 	, sum(allocate_points.points) as points 
from dannys_diner.sales 
	left join allocate_points on sales.product_id = allocate_points.product_id
group by customer_id    
;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

