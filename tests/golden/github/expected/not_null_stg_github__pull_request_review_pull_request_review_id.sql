select pull_request_review_id
from "github"."main_github_source"."stg_github__pull_request_review"
where pull_request_review_id is null
