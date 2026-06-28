-- Write your PostgreSQL query statement below
with PrevNext as(
    select
        id,
        visit_date,
        people,
        lag(id,2) over (order by id) as prev2,
        lag(id,1) over (order by id) as prev1,
        lead(id,1) over (order by id) as next1,
        lead(id,2) over (order by id) as next2
    from Stadium
    where people >= 100
)

select
    id,
    visit_date,
    people
from PrevNext
where
    (prev2 = id-2 and prev1 = id-1)
    or
    (prev1 = id-1 and next1=id+1)
    or
    (next1=id+1 and next2=id+2)
