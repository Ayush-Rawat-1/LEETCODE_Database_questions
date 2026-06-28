-- Write your PostgreSQL query statement below

select
    t.request_at as Day,
    coalesce(round(
            avg(CASE WHEN t.status != 'completed' THEN 1.0 ELSE 0 END)
        ,2) ,0.0) as "Cancellation Rate"
from Trips t
join Users c
on t.client_id = c.users_id 
join Users dr 
on t.driver_id = dr.users_id
where c.banned = 'No' and dr.banned = 'No' and (t.request_at in ('2013-10-01', '2013-10-02', '2013-10-03'))
group by t.request_at
