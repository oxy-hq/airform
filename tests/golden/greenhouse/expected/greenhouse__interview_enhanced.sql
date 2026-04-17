with  __dbt__cte__int_greenhouse__interview_scorecard as (
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
),  __dbt__cte__int_greenhouse__application_users as (
with greenhouse_user as (

    select *
    from __dbt__cte__int_greenhouse__user_emails
),

application as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__application"
),

-- necessary users = credited_to_user (ie referrer), prospect_owner
join_user_names as (

    select
        application.*,
        referrer.full_name as referrer_name,
        prospect_owner.full_name as prospect_owner_name

    from application

    left join greenhouse_user as referrer
        on application.credited_to_user_id = referrer.user_id
        and application.source_relation = referrer.source_relation
    left join greenhouse_user as prospect_owner
        on application.prospect_owner_user_id = prospect_owner.user_id
        and application.source_relation = prospect_owner.source_relation

)

select *
from join_user_names
),  __dbt__cte__int_greenhouse__candidate_tags as (
with greeenhouse_tag as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__tag"
),

candidate_tag as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__candidate_tag"
),

agg_tags as (

    select
        candidate_tag.source_relation,
        candidate_tag.candidate_id,
        
    string_agg(greeenhouse_tag.tag_name, ', ')

 as tags 

    from candidate_tag 
    join greeenhouse_tag
        on candidate_tag.tag_id = greeenhouse_tag.tag_id
        and candidate_tag.source_relation = greeenhouse_tag.source_relation

    group by 1, 2
)

select * 
from agg_tags
),  __dbt__cte__int_greenhouse__hiring_team as (
with hiring_team as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__hiring_team"
),

greenhouse_user as (

    select *
    from __dbt__cte__int_greenhouse__user_emails
),

user_info as (

    select
        hiring_team.source_relation,
        hiring_team.job_id,
        case when lower(role) = 'recruiters' then greenhouse_user.full_name end as recruiter_name,
        case when lower(role) = 'hiring_managers' then greenhouse_user.full_name end as hiring_manager_name,
        case when lower(role) = 'coordinators' then greenhouse_user.full_name end as coordinator_name,
        case when lower(role) = 'sourcers' then greenhouse_user.full_name end as sourcer_name

    from hiring_team
    join greenhouse_user
        on hiring_team.user_id = greenhouse_user.user_id
        and hiring_team.source_relation = greenhouse_user.source_relation
),

agg_role_types as (

    select
        source_relation,
        job_id,
        
    string_agg(hiring_manager_name, ', ')

 as hiring_managers, -- there can be multiple hiring managers
        
    string_agg(sourcer_name, ', ')

 as sourcers,
        
    string_agg(recruiter_name, ', ')

 as recruiters,
        
    string_agg(coordinator_name, ', ')

 as coordinators

    from user_info
    group by 1, 2
)

select * from agg_role_types
),  __dbt__cte__int_greenhouse__job_offices as (


with job_office as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_office"
),

office as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__office"
),

agg_offices as (

    select
        job_office.source_relation,
        job_id,
        
    string_agg(office.office_name, '; ')

 as offices,
        
    string_agg(office.location_name, '; ')

 as locations

    from job_office
    join office
        on job_office.office_id = office.office_id
        and job_office.source_relation = office.source_relation

    group by 1, 2
)

select * from 
agg_offices
),  __dbt__cte__int_greenhouse__job_departments as (


with job_department as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_department"
),

department as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__department"
),

join_parent_department as (

    select 
        sub.*,
        parent.name as parent_department_name

    from department as sub
        left join department as parent
            on sub.parent_department_id = parent.department_id
            and sub.source_relation = parent.source_relation
),

agg_departments as (

    select
        job_department.source_relation,
        job_id,
        
    string_agg(join_parent_department.name, '; ')

 as departments,
        
    string_agg(join_parent_department.parent_department_name, '; ')

 as parent_departments

    from job_department
    join join_parent_department
        on job_department.department_id = join_parent_department.department_id
        and job_department.source_relation = join_parent_department.source_relation

    group by 1, 2
)

select * from 
agg_departments
),  __dbt__cte__int_greenhouse__job_info as (
with hiring_team as (

    select *
    from __dbt__cte__int_greenhouse__hiring_team
),

job as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job"
),


job_office as (

    select *
    from __dbt__cte__int_greenhouse__job_offices
),



job_department as (

    select *
    from __dbt__cte__int_greenhouse__job_departments
),


final as (

    select 
        job.*,
        hiring_team.hiring_managers,
        hiring_team.sourcers,
        hiring_team.recruiters,
        hiring_team.coordinators

        
        ,
        job_office.offices,
        job_office.locations as office_locations
        

        
        ,
        job_department.departments,
        job_department.parent_departments
        

    from job
    left join hiring_team
        on job.job_id = hiring_team.job_id
        and job.source_relation = hiring_team.source_relation

    
    left join job_office
        on job.job_id = job_office.job_id
        and job.source_relation = job_office.source_relation
    

    
    left join job_department
        on job.job_id = job_department.job_id
        and job.source_relation = job_department.source_relation
    
)

select *
from final
),  __dbt__cte__int_greenhouse__application_info as (
with application as (

    select *
    from __dbt__cte__int_greenhouse__application_users
),

candidate as (

    select *
    from "greenhouse"."main_greenhouse"."int_greenhouse__candidate_users"
),

candidate_tag as (

    select *
    from __dbt__cte__int_greenhouse__candidate_tags
),

job_stage as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_stage"
),

source as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__source"
),

activity as (

    select 
        source_relation,
        candidate_id,
        count(*) as count_activities

    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__activity"
    group by 1, 2
),

-- note: prospect applications can have multiple jobs, while canddiate ones are 1:1
job as (

    select *
    from __dbt__cte__int_greenhouse__job_info
),

job_application as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_application"
),


eeoc as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__eeoc"
),



prospect_pool as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__prospect_pool"
),

prospect_stage as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__prospect_stage"
),


join_info as (

    select 
        application.*,
        -- remove/rename overlapping columns + get custom columns
        
        
*
/* No columns were returned. Maybe the relation doesn't exist yet 
or all columns were excluded. This star is only output during  
dbt compile, and exists to keep SQLFluff happy. */
            
        
        
        ,
        candidate.created_at as candidate_created_at,
        candidate_tag.tags as candidate_tags,
        job_stage.stage_name as current_job_stage,
        source.source_name as sourced_from,
        source.source_type_name as sourced_from_type,
        activity.count_activities,

        job.job_title,
        job.status as job_status,
        job.hiring_managers,
        job.job_id,
        job.requisition_id as job_requisition_id,
        job.sourcers as job_sourcers

        
        ,
        job.offices as job_offices
        

        
        ,
        job.departments as job_departments,
        job.parent_departments as job_parent_departments
        

        
        ,
        prospect_pool.prospect_pool_name as prospect_pool,
        prospect_stage.prospect_stage_name as prospect_stage
        

        
        ,
        eeoc.gender_description as candidate_gender,
        eeoc.disability_status_description as candidate_disability_status,
        eeoc.race_description as candidate_race,
        eeoc.veteran_status_description as candidate_veteran_status
        


    from application
    left join candidate
        on application.candidate_id = candidate.candidate_id
        and application.source_relation = candidate.source_relation
    left join candidate_tag
        on application.candidate_id = candidate_tag.candidate_id
        and application.source_relation = candidate_tag.source_relation
    left join job_stage
        on application.current_stage_id = job_stage.job_stage_id
        and application.source_relation = job_stage.source_relation
    left join source
        on application.source_id = source.source_id
        and application.source_relation = source.source_relation
    left join activity
        on activity.candidate_id = candidate.candidate_id
        and activity.source_relation = candidate.source_relation
    left join job_application
        on application.application_id = job_application.application_id
        and application.source_relation = job_application.source_relation
    left join job
        on job_application.job_id = job.job_id
        and job_application.source_relation = job.source_relation

    
    left join eeoc 
        on eeoc.application_id = application.application_id
        and eeoc.source_relation = application.source_relation
    
    left join prospect_pool 
        on prospect_pool.prospect_pool_id = application.prospect_pool_id
        and prospect_pool.source_relation = application.source_relation
    left join prospect_stage
        on prospect_stage.prospect_stage_id = application.prospect_stage_id
        and prospect_stage.source_relation = application.source_relation
    
),

final as (

    select 
        *,
        md5(cast(coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(application_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(job_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as application_job_key
    
    from join_info
)

select *
from final
), interview as (

    select *
    from __dbt__cte__int_greenhouse__interview_users
),

job_stage as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_stage"
),

-- this has job info!
application as (

    select *
    from __dbt__cte__int_greenhouse__application_info
),

final as (

    select
        interview.*,
        application.full_name as candidate_name,
        job_stage.stage_name as job_stage,
        application.current_job_stage as application_current_job_stage,
        application.status as current_application_status,
        application.job_title,
        application.job_id,

        application.hiring_managers like ('%' || interview.interviewer_name || '%')  as interviewer_is_hiring_manager,
        application.hiring_managers,
        application.recruiter_name

        
        ,
        application.job_offices
        

        
        ,
        application.job_departments,
        application.job_parent_departments
        

        
        ,
        application.candidate_gender,
        application.candidate_disability_status,
        application.candidate_race,
        application.candidate_veteran_status
        

    from interview
    left join job_stage 
        on interview.job_stage_id = job_stage.job_stage_id
        and interview.source_relation = job_stage.source_relation
    left join application 
        on interview.application_id = application.application_id
        and interview.source_relation = application.source_relation
)

select * from final
