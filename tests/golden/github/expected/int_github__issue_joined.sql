with  __dbt__cte__int_github__issue_label_joined as (


with issue_label as (

    select *
    from "github"."main_github_source"."stg_github__issue_label"

), label as (

    select *
    from "github"."main_github_source"."stg_github__label"

), joined as (

    select
        issue_label.source_relation,
        issue_label.issue_id,
        label.label
    from issue_label
    left join label
        on issue_label.label_id = label.label_id
        and issue_label.source_relation = label.source_relation

)

select *
from joined
),  __dbt__cte__int_github__issue_labels as (


with issue_label as (
    select *
    from __dbt__cte__int_github__issue_label_joined
)

select
  source_relation,
  issue_id,
  
    string_agg(label, ', ')

 as labels
from issue_label
group by issue_id, source_relation
),  __dbt__cte__int_github__repository_teams as (


with repository as (
    select *
    from "github"."main_github_source"."stg_github__repository"
),

repo_teams as (
    select *
    from "github"."main_github_source"."stg_github__repo_team"
),

teams as (
    select *
    from "github"."main_github_source"."stg_github__team"
),

team_repo as (
    select
        repository.source_relation,
        repository.repository_id,
        repository.full_name as repository,
        teams.name as team_name
    from repository

    left join repo_teams
        on repository.repository_id = repo_teams.repository_id
        and repository.source_relation = repo_teams.source_relation

    left join teams
        on repo_teams.team_id = teams.team_id
        and repo_teams.source_relation = teams.source_relation
),

final as (
    select
        source_relation,
        repository_id,
        repository,
        
    string_agg(team_name, ', ')

 as repository_team_names
    from team_repo

    group by 1, 2, 3
)

select *
from final
),  __dbt__cte__int_github__issue_assignees as (


with issue_assignee as (
    select *
    from "github"."main_github_source"."stg_github__issue_assignee"
), 

github_user as (
    select *
    from "github"."main_github_source"."stg_github__user"
)

select
  issue_assignee.source_relation,
  issue_assignee.issue_id,
  
    string_agg(github_user.login_name, ', ')

 as assignees
from issue_assignee
join github_user on issue_assignee.user_id = github_user.user_id
  and issue_assignee.source_relation = github_user.source_relation
group by 1, 2
),  __dbt__cte__int_github__issue_open_length as (
with issue as (
    select *
    from "github"."main_github_source"."stg_github__issue"
), 

issue_closed_history as (
    select *
    from "github"."main_github_source"."stg_github__issue_closed_history"
), 

close_events_stacked as (
    select
      source_relation,
      issue_id,
      created_at as updated_at,
      false as is_closed
    from issue -- required because issue_closed_history table does not have a line item for when the issue was opened
    union all
    select
      source_relation,
      issue_id,
      updated_at,
      is_closed
    from issue_closed_history
),

close_events_with_timestamps as (
  select
    source_relation,
    issue_id,
    updated_at as valid_starting,
    coalesce(lead(updated_at) over (partition by issue_id, source_relation order by updated_at), now()) as valid_until,
    is_closed
  from close_events_stacked
)

select
  source_relation,
  issue_id,
  sum(date_diff('second', valid_starting::timestamp, valid_until::timestamp )) /60/60/24 as days_issue_open,
  count(*) - 1 as number_of_times_reopened
from close_events_with_timestamps
  where not is_closed
group by issue_id, source_relation
),  __dbt__cte__int_github__issue_comments as (
with issue_comment as (
    select *
    from "github"."main_github_source"."stg_github__issue_comment"
)

select
  source_relation,
  issue_id,
  count(*) as number_of_comments
from issue_comment
group by issue_id, source_relation
),  __dbt__cte__int_github__pull_request_times as (
with issue as (
    select *
    from "github"."main_github_source"."stg_github__issue"
), 

issue_merged as (
    select
      source_relation,
      issue_id,
      min(merged_at) as merged_at
      from "github"."main_github_source"."stg_github__issue_merged"
    group by 1, 2
)



, pull_request_review as (
    select *
    from "github"."main_github_source"."stg_github__pull_request_review"
), 


pull_request as (
    select *
    from "github"."main_github_source"."stg_github__pull_request"
), 

requested_reviewer_history as (
    select *
    from "github"."main_github_source"."stg_github__requested_reviewer_history"
    where not removed
), 

first_request_time as (
    select
      pull_request.source_relation,
      pull_request.issue_id,
      pull_request.pull_request_id,
      -- Finds the first review that is by the requested reviewer and is not a dismissal
      min(case when requested_reviewer_history.requested_id = pull_request_review.user_id then
          case when lower(pull_request_review.state) in ('commented', 'approved', 'changes_requested')
                then pull_request_review.submitted_at end
      else null end) as time_of_first_requested_reviewer_review,
      min(requested_reviewer_history.created_at) as time_of_first_request,
      min(pull_request_review.submitted_at) as time_of_first_review_post_request
    from pull_request
    left join requested_reviewer_history 
      on requested_reviewer_history.pull_request_id = pull_request.pull_request_id
      and requested_reviewer_history.source_relation = pull_request.source_relation
    left join pull_request_review
      on pull_request_review.pull_request_id = pull_request.pull_request_id
      and pull_request_review.source_relation = pull_request.source_relation
      and pull_request_review.submitted_at > requested_reviewer_history.created_at
      and pull_request_review.source_relation = requested_reviewer_history.source_relation
    group by 1, 2, 3
)

select
  first_request_time.source_relation,
  first_request_time.issue_id,
  issue_merged.merged_at,
  date_diff('second', first_request_time.time_of_first_request::timestamp, coalesce(first_request_time.time_of_first_review_post_request, now())::timestamp )/ 60/60 as hours_request_review_to_first_review,
  date_diff('second', first_request_time.time_of_first_request::timestamp, least(
                            coalesce(first_request_time.time_of_first_requested_reviewer_review, now()),
                            coalesce(issue.closed_at, now()))::timestamp ) / 60/60 as hours_request_review_to_first_action,
  date_diff('second', first_request_time.time_of_first_request::timestamp, merged_at::timestamp )/ 60/60 as hours_request_review_to_merge
from first_request_time
join issue 
  on first_request_time.issue_id = issue.issue_id
  and first_request_time.source_relation = issue.source_relation
left join issue_merged 
  on first_request_time.issue_id = issue_merged.issue_id
  and first_request_time.source_relation = issue_merged.source_relation
),  __dbt__cte__int_github__pull_request_reviewers as (
with pull_request_review as (
    select *
    from "github"."main_github_source"."stg_github__pull_request_review"
), 

github_user as (
    select *
    from "github"."main_github_source"."stg_github__user"
),

actual_reviewers as (
  select
    pull_request_review.source_relation,
    pull_request_review.pull_request_id,
    
    string_agg(distinct github_user.login_name, ', ')

 as reviewers,
    count(*) as number_of_reviews
from pull_request_review
left join github_user on pull_request_review.user_id = github_user.user_id
  and pull_request_review.source_relation = github_user.source_relation
group by 1, 2
),


requested_reviewer_history as (

    select *
    from "github"."main_github_source"."stg_github__requested_reviewer_history"
    where removed = false
),

requested_reviewers as (
  select
    requested_reviewer_history.source_relation,
    requested_reviewer_history.pull_request_id,
    
    string_agg(distinct github_user.login_name, ', ')

 as requested_reviewers
from requested_reviewer_history
left join github_user on requested_reviewer_history.requested_id = github_user.user_id
  and requested_reviewer_history.source_relation = github_user.source_relation
group by 1, 2
),


joined as (
  select
    actual_reviewers.source_relation,
    actual_reviewers.pull_request_id,
    actual_reviewers.reviewers,
    requested_reviewers.requested_reviewers,
    
    actual_reviewers.number_of_reviews
  from actual_reviewers
  
  full outer join requested_reviewers
    on requested_reviewers.pull_request_id = actual_reviewers.pull_request_id
    and requested_reviewers.source_relation = actual_reviewers.source_relation
  )

select *
from joined
), issue as (
    select *
    from "github"."main_github_source"."stg_github__issue"
),
issue_labels as (
    select *
    from __dbt__cte__int_github__issue_labels
), 
repository_teams as (
    select
    
      *
    from __dbt__cte__int_github__repository_teams

    
),
issue_assignees as (
    select *
    from __dbt__cte__int_github__issue_assignees
), 
issue_open_length as (
    select *
    from __dbt__cte__int_github__issue_open_length
), 

issue_comments as (
    select *
    from __dbt__cte__int_github__issue_comments
), 

creator as (
    select *
    from "github"."main_github_source"."stg_github__user"
), 

pull_request_times as (
    select *
    from __dbt__cte__int_github__pull_request_times
), 

pull_request_reviewers as (
    select *
    from __dbt__cte__int_github__pull_request_reviewers
), 

pull_request as (
    select *
    from "github"."main_github_source"."stg_github__pull_request"
)

select
  issue.*,
  case 
    when issue.is_pull_request then 'https://github.com/' || repository_teams.repository || '/pull/' || issue.issue_number
    else 'https://github.com/' || repository_teams.repository || '/issues/' || issue.issue_number
  end as url_link,
  issue_open_length.days_issue_open,
  issue_open_length.number_of_times_reopened,labels.labels,issue_comments.number_of_comments,
  repository_teams.repository,
  repository_teams.repository_team_names,
  issue_assignees.assignees,creator.login_name as creator_login_name,
  creator.name as creator_name,
  creator.company as creator_company,pull_request_times.hours_request_review_to_first_review,
  pull_request_times.hours_request_review_to_first_action,
  pull_request_times.hours_request_review_to_merge,
  

  pull_request_times.merged_at,
  pull_request_reviewers.reviewers, 
  
  pull_request_reviewers.requested_reviewers,
  pull_request_reviewers.number_of_reviews
  
from issue
left join issue_labels as labels
  on issue.issue_id = labels.issue_id
  and issue.source_relation = labels.source_relation
join repository_teams
  on issue.repository_id = repository_teams.repository_id
  and issue.source_relation = repository_teams.source_relation
left join issue_assignees
  on issue.issue_id = issue_assignees.issue_id
  and issue.source_relation = issue_assignees.source_relation
left join issue_open_length
  on issue.issue_id = issue_open_length.issue_id
  and issue.source_relation = issue_open_length.source_relation
left join issue_comments
  on issue.issue_id = issue_comments.issue_id
  and issue.source_relation = issue_comments.source_relation
left join creator
  on issue.user_id = creator.user_id
  and issue.source_relation = creator.source_relation
left join pull_request
  on issue.issue_id = pull_request.issue_id
  and issue.source_relation = pull_request.source_relation
left join pull_request_times
  on issue.issue_id = pull_request_times.issue_id
  and issue.source_relation = pull_request_times.source_relation
left join pull_request_reviewers
  on pull_request.pull_request_id = pull_request_reviewers.pull_request_id
  and pull_request.source_relation = pull_request_reviewers.source_relation
