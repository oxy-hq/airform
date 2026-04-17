with  __dbt__cte__int_jira__project_metrics as (
with issue as (

    select * 
    from "jira"."main_jira"."jira__issue_enhanced"
    where project_id is not null
),

calculate_medians as (

    select
        project_id,
        source_relation,
        round(cast(

    percentile_cont( 
        0.5 )
        within group ( order by case when resolved_at is not null then open_duration_seconds end )
        over ( partition by project_id )

 as numeric(28,6) ), 0) as median_close_time_seconds,
        round(cast(

    percentile_cont( 
        0.5 )
        within group ( order by case when resolved_at is null then open_duration_seconds end )
        over ( partition by project_id )

 as numeric(28,6) ), 0) as median_age_currently_open_seconds,
        round(cast(

    percentile_cont( 
        0.5 )
        within group ( order by case when resolved_at is not null then any_assignment_duration_seconds end )
        over ( partition by project_id )

 as numeric(28,6) ), 0) as median_assigned_close_time_seconds,
        round(cast(

    percentile_cont( 
        0.5 )
        within group ( order by case when resolved_at is null then any_assignment_duration_seconds end )
        over ( partition by project_id )

 as numeric(28,6) ), 0) as median_age_currently_open_assigned_seconds
    from issue

    
),

-- grouping because the medians were calculated using window functions (except in postgres)
median_metrics as (

    select
        project_id,
        source_relation,
        median_close_time_seconds,
        median_age_currently_open_seconds,
        median_assigned_close_time_seconds,
        median_age_currently_open_assigned_seconds
    from calculate_medians
    group by 1,2,3,4,5,6
),


-- get appropriate counts + sums to calculate averages
project_issues as (

    select
        project_id,
        source_relation,
        sum(case when resolved_at is not null then 1 else 0 end) as count_closed_issues,
        sum(case when resolved_at is null then 1 else 0 end) as count_open_issues,
        -- using the below to calculate averages
        -- assigned issues
        sum(case when resolved_at is null and assignee_user_id is not null then 1 else 0 end) as count_open_assigned_issues,
        sum(case when resolved_at is not null and assignee_user_id is not null then 1 else 0 end) as count_closed_assigned_issues,
        -- close time
        sum(case when resolved_at is not null then open_duration_seconds else 0 end) as sum_close_time_seconds,
        sum(case when resolved_at is not null then any_assignment_duration_seconds else 0 end) as sum_assigned_close_time_seconds,
        -- age of currently open tasks
        sum(case when resolved_at is null then open_duration_seconds else 0 end) as sum_currently_open_duration_seconds,
        sum(case when resolved_at is null then any_assignment_duration_seconds else 0 end) as sum_currently_open_assigned_duration_seconds
    from issue

    group by 1, 2
),

calculate_avg_metrics as (

    select
        project_id,
        source_relation,
        count_closed_issues,
        count_open_issues,
        count_open_assigned_issues,
        case when count_closed_issues = 0 then 0 
            else round(cast(sum_close_time_seconds * 1.0 / count_closed_issues  as numeric(28,6) ), 0) end as avg_close_time_seconds,
        case when count_closed_assigned_issues = 0 then 0 
            else round(cast(sum_assigned_close_time_seconds * 1.0 / count_closed_assigned_issues  as numeric(28,6) ), 0) end as avg_assigned_close_time_seconds,
        case when count_open_issues = 0 then 0 
            else round(cast(sum_currently_open_duration_seconds * 1.0 / count_open_issues as numeric(28,6) ), 0) end as avg_age_currently_open_seconds,
        case when count_open_assigned_issues = 0 then 0 
            else round(cast(sum_currently_open_assigned_duration_seconds * 1.0 / count_open_assigned_issues as numeric(28,6) ), 0) end as avg_age_currently_open_assigned_seconds
    from project_issues
),

-- join medians and averages + convert to days
join_metrics as (

    select
        calculate_avg_metrics.*,
        -- there are 86400 seconds in a day
        round(cast(calculate_avg_metrics.avg_close_time_seconds / 86400.0 as numeric(28,6) ), 0) as avg_close_time_days,
        round(cast(calculate_avg_metrics.avg_assigned_close_time_seconds / 86400.0 as numeric(28,6) ), 0) as avg_assigned_close_time_days,
        round(cast(calculate_avg_metrics.avg_age_currently_open_seconds / 86400.0 as numeric(28,6) ), 0) as avg_age_currently_open_days,
        round(cast(calculate_avg_metrics.avg_age_currently_open_assigned_seconds / 86400.0 as numeric(28,6) ), 0) as avg_age_currently_open_assigned_days,
        median_metrics.median_close_time_seconds, 
        median_metrics.median_age_currently_open_seconds,
        median_metrics.median_assigned_close_time_seconds,
        median_metrics.median_age_currently_open_assigned_seconds,
        round(cast(median_metrics.median_close_time_seconds / 86400.0 as numeric(28,6) ), 0) as median_close_time_days,
        round(cast(median_metrics.median_age_currently_open_seconds / 86400.0 as numeric(28,6) ), 0) as median_age_currently_open_days,
        round(cast(median_metrics.median_assigned_close_time_seconds / 86400.0 as numeric(28,6) ), 0) as median_assigned_close_time_days,
        round(cast(median_metrics.median_age_currently_open_assigned_seconds / 86400.0 as numeric(28,6) ), 0) as median_age_currently_open_assigned_days
    from calculate_avg_metrics
    left join median_metrics
        on calculate_avg_metrics.project_id = median_metrics.project_id
        and calculate_avg_metrics.source_relation = median_metrics.source_relation
)

select * 
from join_metrics
), project as (

    select *
    from "jira"."main_jira_source"."stg_jira__project"
),

project_metrics as (

    select * 
    from __dbt__cte__int_jira__project_metrics
),

-- user is reserved in AWS
jira_user as (
-- to grab the project lead
    select *
    from "jira"."main_jira_source"."stg_jira__user"
),

agg_epics as (

    select
        project_id,
        source_relation,
        
    string_agg(issue_name, ', ')

 as epics

    from "jira"."main_jira"."jira__issue_enhanced"
    where lower(issue_type) = 'epic'
    -- should we limit to active epics?
    group by 1, 2
),



agg_components as (
    -- i'm just aggregating the components here, but perhaps pivoting out components (and epics)
    -- into columns where the values are the number of issues completed and/or open would be more valuable
    select
        project_id,
        source_relation,
        
    string_agg(component_name, ', ')

 as components
    from "jira"."main_jira_source"."stg_jira__component"
    group by 1, 2
),



project_join as (

    select
        project.*,
        jira_user.user_display_name as project_lead_user_name,
        jira_user.email as project_lead_email,
        agg_epics.epics,
        
        
        agg_components.components,
        

        coalesce(project_metrics.count_closed_issues, 0) as count_closed_issues,
        coalesce(project_metrics.count_open_issues, 0) as count_open_issues,
        coalesce(project_metrics.count_open_assigned_issues, 0) as count_open_assigned_issues,

        -- days
        project_metrics.avg_close_time_days,
        project_metrics.avg_assigned_close_time_days,

        project_metrics.avg_age_currently_open_days,
        project_metrics.avg_age_currently_open_assigned_days,

        project_metrics.median_close_time_days, 
        project_metrics.median_age_currently_open_days,
        project_metrics.median_assigned_close_time_days,
        project_metrics.median_age_currently_open_assigned_days,

        -- seconds
        project_metrics.avg_close_time_seconds,
        project_metrics.avg_assigned_close_time_seconds,

        project_metrics.avg_age_currently_open_seconds,
        project_metrics.avg_age_currently_open_assigned_seconds,

        project_metrics.median_close_time_seconds, 
        project_metrics.median_age_currently_open_seconds,
        project_metrics.median_assigned_close_time_seconds,
        project_metrics.median_age_currently_open_assigned_seconds

    from project
    left join project_metrics
        on project.project_id = project_metrics.project_id
        and project.source_relation = project_metrics.source_relation
    left join jira_user
        on project.project_lead_user_id = jira_user.user_id
        and project.source_relation = jira_user.source_relation
    left join agg_epics
        on project.project_id = agg_epics.project_id
        and project.source_relation = agg_epics.source_relation

    
    left join agg_components
        on project.project_id = agg_components.project_id
        and project.source_relation = agg_components.source_relation
    

)

select * 
from project_join
