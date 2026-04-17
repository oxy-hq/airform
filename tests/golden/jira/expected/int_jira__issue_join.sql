with  __dbt__cte__int_jira__issue_users as (
-- just grabs user attributes for issue assignees and reporters 

with issue as (

    -- including issue_id in here because snowflake for some reason ignores issue_id,
    -- so we'll just always pull it out and explicitly select it
    

    select
        issue_id,
        coalesce(cast(revised_parent_issue_id as TEXT), cast(parent_issue_id as TEXT)) as parent_issue_id,

        
*
/* No columns were returned. Maybe the relation doesn't exist yet 
or all columns were excluded. This star is only output during  
dbt compile, and exists to keep SQLFluff happy. */
            

    from "jira"."main_int_jira"."int_jira__issue_type_parents"
),

-- user is a reserved keyword in AWS
jira_user as (

    select *
    from "jira"."main_jira_source"."stg_jira__user"
),

issue_user_join as (

    select
        issue.*,
        assignee.user_display_name as assignee_name,
        assignee.time_zone as assignee_timezone,
        assignee.email as assignee_email,
        reporter.email as reporter_email,
        reporter.user_display_name as reporter_name,
        reporter.time_zone as reporter_timezone
    from issue
    left join jira_user as assignee
        on issue.assignee_user_id = assignee.user_id
        and issue.source_relation = assignee.source_relation
    left join jira_user as reporter
        on issue.reporter_user_id = reporter.user_id
        and issue.source_relation = reporter.source_relation
)

select * 
from issue_user_join
),  __dbt__cte__int_jira__issue_multiselect_history as (
with issue_multiselect_history as (

    select *
    from "jira"."main_jira_source"."stg_jira__issue_multiselect_history"
    
), 

fields as (
      
    select *
    from "jira"."main_jira_source"."stg_jira__field"

), 

joined as (

  select
    issue_multiselect_history.*,
    lower(fields.field_name) as field_name,
    cast(date_trunc('week', issue_multiselect_history.updated_at) as date) as updated_at_week

  from issue_multiselect_history
  join fields
    on fields.field_id = issue_multiselect_history.field_id
    and fields.source_relation = issue_multiselect_history.source_relation

)

select *
from joined
),  __dbt__cte__int_jira__issue_sprint as (


with sprint as (

    select * 
    from "jira"."main_jira_source"."stg_jira__sprint"
),

field_history as (

    -- sprints don't appear to be capable of multiselect in the UI...
    select *
    from __dbt__cte__int_jira__issue_multiselect_history
),

sprint_field_history as (

    select
        field_history.*,
        sprint.sprint_id,
        sprint.sprint_name,
        sprint.board_id,
        sprint.completed_at,
        sprint.ended_at,
        sprint.started_at,
        sprint._fivetran_synced,
        row_number() over (
                    partition by field_history.issue_id 
                    order by field_history.updated_at desc, sprint.started_at desc
                    ) as row_num
    from field_history
    left join sprint
        on field_history.field_value = cast(sprint.sprint_id as TEXT)
        and field_history.source_relation = sprint.source_relation
    where lower(field_history.field_name) = 'sprint'
),

last_sprint as (

    select *
    from sprint_field_history
    where row_num = 1
), 

sprint_rollovers as (

    select
        issue_id,
        source_relation,
        count(distinct case when field_value is not null then field_value end) as count_sprint_changes
    from sprint_field_history
    group by 1, 2
),

issue_sprint as (

    select
        last_sprint.issue_id,
        last_sprint.source_relation,
        last_sprint.field_value as current_sprint_id,
        last_sprint.sprint_name as current_sprint_name,
        last_sprint.board_id,
        last_sprint.started_at as sprint_started_at,
        last_sprint.ended_at as sprint_ended_at,
        last_sprint.completed_at as sprint_completed_at,
        coalesce(sprint_rollovers.count_sprint_changes, 0) as count_sprint_changes
    from last_sprint
    left join sprint_rollovers
        on sprint_rollovers.issue_id = last_sprint.issue_id
        and sprint_rollovers.source_relation = last_sprint.source_relation
)

select *
from issue_sprint
),  __dbt__cte__int_jira__issue_comments as (


with comment as (

    select *
    from "jira"."main_jira_source"."stg_jira__comment"
    order by issue_id, created_at asc
),

-- user is a reserved keyword in AWS 
jira_user as (

    select *
    from "jira"."main_jira_source"."stg_jira__user"
),

agg_comments as (

    select
    comment.issue_id,
    comment.source_relation,
    count(comment.comment_id) as count_comments
    ,
    string_agg(comment.created_at || '  -  ' || jira_user.user_display_name || ':  ' || comment.body, '\n')

 as conversation
    

    from comment
    inner join jira_user
        on comment.author_user_id = jira_user.user_id
        and comment.source_relation = jira_user.source_relation
    group by 1, 2
)

select * from agg_comments
),  __dbt__cte__int_jira__issue_field_history as (
with field_history as (

    select *
    from "jira"."main_jira_source"."stg_jira__issue_field_history"
    
), 

fields as (
      
    select *
    from "jira"."main_jira_source"."stg_jira__field"

), 

joined as (

  select
    field_history.*,
    lower(fields.field_name) as field_name,
    cast(date_trunc('week', field_history.updated_at) as date) as updated_at_week

  from field_history
  join fields
    on fields.field_id = field_history.field_id
    and fields.source_relation = field_history.source_relation

)

select *
from joined
),  __dbt__cte__int_jira__issue_assign_resolution as (
with issue_field_history as (
    
    select *
    from __dbt__cte__int_jira__issue_field_history
),

filtered as (
    -- we're only looking at assignments and resolutions, which are single-field values
    select *
    from issue_field_history
    where (lower(field_id) = 'assignee'
        or lower(field_id) = 'resolutiondate')
        and field_value is not null -- remove initial null rows
),

issue_dates as (

    select
        issue_id,
        source_relation,
        min(case when field_id = 'assignee' then updated_at end) as first_assigned_at,
        max(case when field_id = 'assignee' then updated_at end) as last_assigned_at,
        min(case when field_id = 'resolutiondate' then updated_at end) as first_resolved_at -- in case it's been re-opened
    from filtered
    group by 1, 2
)

select *
from issue_dates
),  __dbt__cte__int_jira__issue_versions as (


with version as (

    select *
    from "jira"."main_jira_source"."stg_jira__version"
),

version_history as (

    select *
    from __dbt__cte__int_jira__issue_multiselect_history
    where field_id = 'versions'
        or field_id = 'fixVersions'
),

order_versions as (

    select
        *,
        -- using rank so batches stick together
        rank() over (
            partition by field_id, issue_id 
            order by updated_at desc
            ) as row_num
    from version_history
),

latest_versions as (

    select
        field_id,
        issue_id,
        source_relation,
        updated_at,
        cast(field_value as integer) as version_id
    from order_versions
    where row_num = 1
),

version_info as (

    select
        latest_versions.field_id,
        latest_versions.issue_id,
        latest_versions.source_relation,
        
    string_agg(version.version_name, ', ')

 as versions

    from latest_versions
    join version on latest_versions.version_id = version.version_id
        and latest_versions.source_relation = version.source_relation

    group by 1,2,3
),

split_versions as (

    select
        issue_id,
        source_relation,
        case when field_id = 'versions' then versions else null end as affects_versions,
        case when field_id = 'fixVersions' then versions else null end as fixes_versions
    from version_info
),

final as (

    select
        issue_id,
        source_relation,
        max(affects_versions) as affects_versions,
        max(fixes_versions) as fixes_versions
    from split_versions
    group by 1, 2
)

select *
from final
), issue as (

    select *
    from __dbt__cte__int_jira__issue_users

),

project as (

    select * 
    from "jira"."main_jira_source"."stg_jira__project"
),

status as (

    select * 
    from "jira"."main_jira_source"."stg_jira__status"
),

status_category as (

    select * 
    from "jira"."main_jira_source"."stg_jira__status_category"
),

resolution as (

    select * 
    from "jira"."main_jira_source"."stg_jira__resolution"
),


priority as (

    select * 
    from "jira"."main_jira_source"."stg_jira__priority"
),



issue_sprint as (

    select *
    from __dbt__cte__int_jira__issue_sprint
),



issue_comments as (

    select * 
    from __dbt__cte__int_jira__issue_comments
),


issue_assignments_and_resolutions as (

    select *
    from __dbt__cte__int_jira__issue_assign_resolution
),


issue_versions as (

    select *
    from __dbt__cte__int_jira__issue_versions
),


join_issue as (

    select
        issue.*
        ,project.project_name as project_name
        ,status.status_name as current_status
        ,status_category.status_category_name as current_status_category
        ,resolution.resolution_name as resolution_type

        
        ,priority.priority_name as current_priority
	

        
        ,issue_sprint.current_sprint_id
        ,issue_sprint.current_sprint_name
        ,coalesce(issue_sprint.count_sprint_changes, 0) as count_sprint_changes
        ,issue_sprint.sprint_started_at
        ,issue_sprint.sprint_ended_at
        ,issue_sprint.sprint_completed_at
        ,coalesce(issue_sprint.sprint_started_at <= now()
            and coalesce(issue_sprint.sprint_completed_at, now()) >= now()  
            , false) as is_active_sprint -- If sprint doesn't have a start date, default to false. If it does have a start date, but no completed date, this means that the sprint is active. The ended_at timestamp is irrelevant here.
        

        ,issue_assignments_and_resolutions.first_assigned_at
        ,issue_assignments_and_resolutions.last_assigned_at
        ,issue_assignments_and_resolutions.first_resolved_at

        
        ,issue_versions.fixes_versions
        ,issue_versions.affects_versions
        

        
        ,issue_comments.conversation
        ,coalesce(issue_comments.count_comments, 0) as count_comments
        

    from issue
    left join project
        on project.project_id = issue.project_id
        and project.source_relation = issue.source_relation
    left join status
        on status.status_id = issue.status_id
        and status.source_relation = issue.source_relation
    left join status_category
        on status.status_category_id = status_category.status_category_id
        and status.source_relation = status_category.source_relation
    left join resolution
        on resolution.resolution_id = issue.resolution_id
        and resolution.source_relation = issue.source_relation

	
    left join priority
        on priority.priority_id = issue.priority_id
        and priority.source_relation = issue.source_relation
	
    left join issue_assignments_and_resolutions
        on issue_assignments_and_resolutions.issue_id = issue.issue_id
        and issue_assignments_and_resolutions.source_relation = issue.source_relation

    
    left join issue_versions
        on issue_versions.issue_id = issue.issue_id
        and issue_versions.source_relation = issue.source_relation
    

    
    left join issue_sprint
        on issue_sprint.issue_id = issue.issue_id
        and issue_sprint.source_relation = issue.source_relation
    

    
    left join issue_comments
        on issue_comments.issue_id = issue.issue_id
        and issue_comments.source_relation = issue.source_relation
    
)

select *
from join_issue
