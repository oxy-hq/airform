with __dbt__cte__int_greenhouse__interview_scorecard as (
with scorecard as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__scorecard"
),

scheduled_interviewer as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__scheduled_interviewer"
),

scheduled_interview as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__scheduled_interview"
),

interview as (
    
    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__interview"
),

interview_w_scorecard as (

    select
        scheduled_interview.*,

        interview.job_stage_id,
        coalesce(interview.name, scorecard.interview_name) as interview_name,
        date_diff('minute', scheduled_interview.start_at::timestamp, scheduled_interview.end_at::timestamp ) as duration_interview_minutes,
        scorecard.scorecard_id,
        scorecard.candidate_id,
        scorecard.overall_recommendation,
        scorecard.submitted_at as scorecard_submitted_at,
        scorecard.submitted_by_user_id as scorecard_submitted_by_user_id,
        scorecard.last_updated_at as scorecard_last_updated_at,

        scheduled_interviewer.interviewer_user_id
        

    from scheduled_interview
    left join scheduled_interviewer
        on scheduled_interview.scheduled_interview_id = scheduled_interviewer.scheduled_interview_id
        and scheduled_interview.source_relation = scheduled_interviewer.source_relation
    left join scorecard
        on scheduled_interviewer.scorecard_id = scorecard.scorecard_id
        and scheduled_interviewer.source_relation = scorecard.source_relation
    left join interview
        on scheduled_interview.interview_id = interview.interview_id
        and scheduled_interview.source_relation = interview.source_relation
),

-- add surrogate key for tests
final as (

    select
        *,
        md5(cast(coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(scheduled_interview_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(interviewer_user_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as interview_scorecard_key
    
    from interview_w_scorecard
)

select *
from final
) select
    interview_scorecard_key as unique_field,
    count(*) as n_records

from __dbt__cte__int_greenhouse__interview_scorecard
where interview_scorecard_key is not null
group by interview_scorecard_key
having count(*) > 1
