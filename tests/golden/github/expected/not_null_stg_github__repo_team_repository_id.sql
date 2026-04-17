select repository_id
from "github"."main_github_source"."stg_github__repo_team"
where repository_id is null
