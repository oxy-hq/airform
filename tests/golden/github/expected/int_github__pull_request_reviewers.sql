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
