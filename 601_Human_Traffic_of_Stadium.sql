-- Write your PostgreSQL query statement below
with PrevNext as(
    select
        id,
        visit_date,
        people,
        lag(people,2) over (order by id) as prev2,
        lag(people,1) over (order by id) as prev1,
        lead(people,1) over (order by id) as next1,
        lead(people,2) over (order by id) as next2
    from Stadium
)

select
    id,
    visit_date,
    people
from PrevNext
where
    people >= 100 and
    ((prev2>=100 and prev1>=100)
    or
    (prev1>=100 and next1>=100)
    or
    (next1>=100 and next2>=100))
