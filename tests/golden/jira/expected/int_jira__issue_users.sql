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
