with hiring_team as (

    select *
    from main_stg_greenhouse.stg_greenhouse__hiring_team
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
        STRING_AGG(hiring_manager_name, ', ') as hiring_managers, -- there can be multiple hiring managers
        STRING_AGG(sourcer_name, ', ') as sourcers,
        STRING_AGG(recruiter_name, ', ') as recruiters,
        STRING_AGG(coordinator_name, ', ') as coordinators

    from user_info
    group by 1, 2
)

select * from agg_role_types
