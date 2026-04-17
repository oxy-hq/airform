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
