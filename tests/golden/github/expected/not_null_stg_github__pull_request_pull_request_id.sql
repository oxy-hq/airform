select pull_request_id
from "github"."main_github_source"."stg_github__pull_request"
where pull_request_id is null
