-- Write your PostgreSQL query statement below

with cte as(
    select
        p.user_id,
        i.category
    from ProductPurchases p
    join ProductInfo i
    on p.product_id = i.product_id
)

select
    a.category as category1,
    b.category as category2,
    count(distinct a.user_id) as customer_count
from cte a
join cte b
on a.user_id = b.user_id and a.category < b.category
group by a.category,b.category
having count(distinct a.user_id) >= 3
order by customer_count desc, category1, category2
