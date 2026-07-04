-- Write your PostgreSQL query statement below

with recursive

cte1 as(
    select
        user_id,
        action_date,
        action,
        row_number() over (partition by user_id,action order by action_date) as rnk
    from activity
),
cte2 as(
    select
        user_id,
        action_date,
        action,
        rnk,
        1 as count
    from cte1
    where rnk = 1

    UNION ALL

    select
        b.user_id,
        b.action_date,
        b.action,
        b.rnk,
        CASE 
            WHEN b.action_date - a.action_date = 1 THEN a.count+1
            ELSE 1
        END as count
    from cte2 a
    join cte1 b
    on a.user_id = b.user_id and a.rnk+1 = b.rnk and a.action = b.action
),
cte3 as(
    select
        user_id,
        max(count) as streak_length
    from cte2
    group by user_id
    having max(count) >= 5
)

select
    cte3.user_id,
    cte2.action,
    cte3.streak_length,
    cte2.action_date - cte3.streak_length + 1 as start_date,
    cte2.action_date as end_date
from cte3
join cte2
on cte3.user_id = cte2.user_id and cte3.streak_length = cte2.count
order by streak_length desc, user_id
