-- Write your PostgreSQL query statement below
with cte as(
select
    session_id,
    user_id,
    extract(epoch from max(event_timestamp) - min(event_timestamp))/60 as session_duration_minutes ,
    count(CASE WHEN event_type = 'purchase' THEN 1 END) as purchase,
    count(CASE WHEN event_type = 'scroll' THEN 1 END) as scroll_count,
    count(CASE WHEN event_type = 'click' THEN 1 END) as click
from app_events
group by user_id, session_id
)

select 
    session_id,
    user_id,
    session_duration_minutes,
    scroll_count
from cte
where purchase = 0 and click*1.0/scroll_count < 0.2 and scroll_count >= 5 and session_duration_minutes > 30
order by scroll_count desc, session_id
