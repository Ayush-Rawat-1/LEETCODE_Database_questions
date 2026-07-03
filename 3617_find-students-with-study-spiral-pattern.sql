-- Write your PostgreSQL query statement below

with recursive
cte as(
    select
        student_id,
        subject::text,
        session_date,
        hours_studied,
        row_number() over (partition by student_id order by session_date,session_id) as rnk
    from study_sessions
),
cte1 as(
    select
        rnk,
        student_id,
        0 as cycle_length,
        0 as idx,
        session_date,
        ARRAY[subject] as subjects
    from cte
    where rnk = 1

    UNION ALL

    select
        cte.rnk,
        cte.student_id,
        CASE
            WHEN cte1.cycle_length = 0 and cte1.subjects[1] = cte.subject 
                THEN array_length(cte1.subjects,1)
            WHEN cte1.cycle_length = 0 and cte1.subjects[1] != cte.subject 
                THEN 0
            WHEN cte1.cycle_length >= 3 and cte1.subjects[((idx+1)%cte1.cycle_length)+1] = cte.subject
                THEN cte1.cycle_length
            WHEN cte1.cycle_length >= 3 and cte1.subjects[((idx+1)%cte1.cycle_length)+1] != cte.subject
                THEN -1
            ELSE -1
        END as cycle_length,
        idx+1,
        cte.session_date,
        subjects || cte.subject as subjects
    from cte
    join cte1
    on cte.rnk = cte1.rnk+1 and cte.student_id = cte1.student_id and cte.session_date - cte1.session_date <= 2
    where cte1.cycle_length not in (-1,2)
),
cte2 as(
    select
        s.student_id,
        s.student_name,
        s.major,
        sum(c.hours_studied) as total_Study_hours,
        max(c.rnk) as max_rnk
    from students s
    join cte c
    on s.student_id = c.student_id
    group by s.student_id, s.student_name, s.major
),
cte3 as(

    select
        s.student_id,
        s.student_name,
        s.major,
        c.cycle_length,
        s.total_study_hours
    from cte1 c
    join cte2 s
    on c.student_id = s.student_id and s.max_rnk = c.rnk
    where c.cycle_length >= 3 and (c.idx+1)%c.cycle_length = 0
    order by cycle_length desc,total_study_hours desc

)

select * from cte3
