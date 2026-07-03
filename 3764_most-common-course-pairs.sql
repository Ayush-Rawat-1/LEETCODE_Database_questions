-- Write your PostgreSQL query statement below

with cte as(
    select
        user_id
    from course_completions
    group by user_id
    having count(course_id) >= 5 and avg(course_rating) >= 4
),
cte1 as(
    select
        cc.course_name as first_course,
        lead(cc.course_name) over (partition by cc.user_id order by cc.completion_date) as second_course
    from cte
    join course_completions cc
    on cte.user_id = cc.user_id
)


select
    first_course,
    second_course,
    count(*) as transition_count
from cte1
where second_course is not null
group by first_course, second_course
order by transition_count desc, lower(first_course), lower(second_course)
