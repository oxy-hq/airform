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
),  __dbt__cte__int_greenhouse__user_emails as (
with user_email as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__user_email"
),

greenhouse_user as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__user"
),

agg_emails as (

    select
        source_relation,
        user_id,
        
    string_agg(email, ', ')

 as email

    from user_email

    group by 1, 2
),

final as (

    select
        greenhouse_user.*,
        agg_emails.email
    from greenhouse_user
    left join agg_emails
        on greenhouse_user.user_id = agg_emails.user_id
        and greenhouse_user.source_relation = agg_emails.source_relation
)

select * 
from final
),  __dbt__cte__int_greenhouse__interview_users as (
with interview as (

    select *
    from __dbt__cte__int_greenhouse__interview_scorecard
),

greenhouse_user as (

    select *
    from __dbt__cte__int_greenhouse__user_emails
),

-- necessary users = interviewer_user_id, scorecard_submitted_by_user_id, organizer_user_id
join_user_names as (

    select
        interview.*,
        interviewer.full_name as interviewer_name,
        scorecard_submitter.full_name as scorecard_submitter_name,
        organizer.full_name as organizer_name,
        interviewer.email as interviewer_email

    from interview

    left join greenhouse_user as interviewer
        on interview.interviewer_user_id = interviewer.user_id
        and interview.source_relation = interviewer.source_relation
    left join greenhouse_user as scorecard_submitter
        on interview.scorecard_submitted_by_user_id = scorecard_submitter.user_id
        and interview.source_relation = scorecard_submitter.source_relation
    left join greenhouse_user as organizer
        on interview.organizer_user_id = organizer.user_id
        and interview.source_relation = organizer.source_relation 

)

select * from join_user_names
) select interview_scorecard_key
from __dbt__cte__int_greenhouse__interview_users
where interview_scorecard_key is null
