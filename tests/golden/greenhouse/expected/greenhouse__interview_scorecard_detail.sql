with interview as (

    select *
    from "greenhouse"."main_greenhouse"."greenhouse__interview_enhanced"
),

scorecard_attribute as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__scorecard_attribute"
),

join_w_attributes as (

    select
        scorecard_attribute.*,
        interview.overall_recommendation,
    
        interview.candidate_name,
        interview.interviewer_name,
        interview.interview_name,
        
        interview.start_at as interview_start_at,
        interview.scorecard_submitted_at,

        interview.application_id,
        interview.job_title,
        interview.job_id,
        interview.hiring_managers,
        interview.interview_scorecard_key
        
    from interview 
    left join scorecard_attribute
        on interview.scorecard_id = scorecard_attribute.scorecard_id
        and interview.source_relation = scorecard_attribute.source_relation
),

final as (

    select 
        *,
        md5(cast(coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(interview_scorecard_key as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(index as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as scorecard_attribute_key

    from join_w_attributes
)

select *
from final
