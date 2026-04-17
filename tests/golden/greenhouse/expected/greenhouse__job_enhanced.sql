with  __dbt__cte__int_greenhouse__user_emails as (
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
), job as (

    select *
    from __dbt__cte__int_greenhouse__job_info
),

job_applications as (

    select 
        source_relation,
        job_id,
        sum(case when not is_prospect and status = 'active' then 1 else 0 end) as count_active_applications,
        sum(case when not is_prospect and status = 'hired' then 1 else 0 end) as count_hired_applications,
        sum(case when not is_prospect and status = 'rejected' then 1 else 0 end) as count_rejected_applications,

        sum(case when count_interviews > 0 then 1 else 0 end) as count_interviewed_applications,

        sum(case when is_prospect and status = 'active' then 1 else 0 end) as count_active_prospects,
        sum(case when is_prospect and status = 'converted' then 1 else 0 end) as count_converted_prospects,
        sum(case when is_prospect and status = 'rejected' then 1 else 0 end) as count_rejected_prospects

    from "greenhouse"."main_greenhouse"."greenhouse__application_enhanced"

    group by 1, 2
),

live_job_posts as (

    select 
        source_relation,
        job_id,
        sum(case when is_internal then 1 else 0 end) as count_live_internal_posts,
        sum(case when is_external then 1 else 0 end) as count_live_external_posts,
        count(distinct lower(location_name)) as count_live_locations

    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_post"

    where is_live

    group by 1, 2
),

job_openings as (

    select 
        source_relation,
        job_id,
        sum(case when current_status = 'open' then 1 else 0 end) as count_active_openings,
        sum(case when current_status = 'closed' then 1 else 0 end) as count_closed_openings,
        sum(case when current_status = 'closed' and application_id is not null then 1 else 0 end) as count_hired_closed_openings
        
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_opening"

    group by 1, 2
),

final as (

    select 
        job.*,
        coalesce(job_applications.count_active_applications, 0) as count_active_applications,
        coalesce(job_applications.count_hired_applications, 0) as count_hired_applications,
        coalesce(job_applications.count_rejected_applications, 0) as count_rejected_applications,
        coalesce(job_applications.count_interviewed_applications, 0) as count_interviewed_applications,
        coalesce(job_applications.count_active_prospects, 0) as count_active_prospects,
        coalesce(job_applications.count_converted_prospects, 0) as count_converted_prospects,
        coalesce(job_applications.count_rejected_prospects, 0) as count_rejected_prospects,

        coalesce(job_openings.count_active_openings, 0) as count_active_openings,
        coalesce(job_openings.count_closed_openings, 0) as count_closed_openings,
        coalesce(job_openings.count_hired_closed_openings, 0) as count_hired_closed_openings,

        coalesce(live_job_posts.count_live_internal_posts, 0) as count_live_internal_posts,
        coalesce(live_job_posts.count_live_external_posts, 0) as count_live_external_posts,
        coalesce(live_job_posts.count_live_locations, 0) as count_live_locations



    from job 
    left join job_applications 
        on job.job_id = job_applications.job_id
        and job.source_relation = job_applications.source_relation
    left join live_job_posts
        on job.job_id = live_job_posts.job_id
        and job.source_relation = live_job_posts.source_relation
    left join job_openings
        on job.job_id = job_openings.job_id
        and job.source_relation = job_openings.source_relation
)

select *
from final
