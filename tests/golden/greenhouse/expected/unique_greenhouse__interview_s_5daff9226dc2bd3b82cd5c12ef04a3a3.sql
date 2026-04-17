select
    scorecard_attribute_key as unique_field,
    count(*) as n_records

from "greenhouse"."main_greenhouse"."greenhouse__interview_scorecard_detail"
where scorecard_attribute_key is not null
group by scorecard_attribute_key
having count(*) > 1
