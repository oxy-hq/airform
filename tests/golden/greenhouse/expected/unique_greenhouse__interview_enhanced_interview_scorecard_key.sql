select
    interview_scorecard_key as unique_field,
    count(*) as n_records

from "greenhouse"."main_greenhouse"."greenhouse__interview_enhanced"
where interview_scorecard_key is not null
group by interview_scorecard_key
having count(*) > 1
