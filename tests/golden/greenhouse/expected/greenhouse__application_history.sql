with application_history as (

    select 
        source_relation,
        application_id,
        new_stage_id,
        new_status,
        updated_at as valid_from,
        coalesce(lead(updated_at) over (partition by application_id  order by updated_at asc),
            
    current_timestamp::timestamp
) as valid_until

    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__application_history"
),

application as (

    select *
    from "greenhouse"."main_greenhouse"."greenhouse__application_enhanced"
),

job_stage as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_stage"
),

activity as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__activity"
),

join_application_history as (

    select 
        application_history.*,
        job_stage.stage_name as new_stage,
        application.full_name,
        application.status as current_status,
        application.recruiter_name,
        application.hiring_managers,
        application.sourced_from, 
        application.sourced_from_type,
        application.job_title,
        application.job_id,
        application.candidate_id
        
        ,
        application.job_departments,
        application.job_parent_departments
        
        
        
        ,
        application.job_offices
        

        
        ,
        application.candidate_gender,
        application.candidate_disability_status,
        application.candidate_race,
        application.candidate_veteran_status
        

    from application_history 
    join application
        on application_history.application_id = application.application_id
        and application_history.source_relation = application.source_relation
    left join job_stage
        on application_history.new_stage_id = job_stage.job_stage_id
        and application_history.source_relation = job_stage.source_relation
),

time_in_stages as (

    select 
        *,
        date_diff('day', valid_from::timestamp, valid_until::timestamp ) as days_in_stage

    from join_application_history
),

activities_in_stages as (

    select
        -- Call out each column for Databricks compatibility
        time_in_stages.source_relation,
        time_in_stages.application_id,
        time_in_stages.new_stage_id,
        time_in_stages.new_status,
        time_in_stages.valid_from,
        time_in_stages.valid_until,
        time_in_stages.new_stage,
        time_in_stages.full_name,
        time_in_stages.current_status,
        time_in_stages.recruiter_name,
        time_in_stages.hiring_managers,
        time_in_stages.sourced_from,
        time_in_stages.sourced_from_type,
        time_in_stages.job_title,
        time_in_stages.job_id,
        time_in_stages.candidate_id,
        time_in_stages.days_in_stage,

        
        time_in_stages.job_departments,
        time_in_stages.job_parent_departments,
        
        
        
        time_in_stages.job_offices,
        

        
        time_in_stages.candidate_gender,
        time_in_stages.candidate_disability_status,
        time_in_stages.candidate_race,
        time_in_stages.candidate_veteran_status,
        

        sum(case when activity.occurred_at >= valid_from and activity.occurred_at < valid_until 
            then 1 else 0 end) as count_activities_in_stage

    from time_in_stages
    left join activity on activity.candidate_id = time_in_stages.candidate_id
        and activity.source_relation = time_in_stages.source_relation

    -- 16 standard columns in join_application_history CTE (including source_relation) + 1 days_in_stage column + 4 more if using the eeoc table + 1 if job_office + 2 if job_department
    
    
    

    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
)

select *
from activities_in_stages
