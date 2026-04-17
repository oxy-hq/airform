with pull_request as (

    select *
    from "github"."main_github_source"."stg_github__pull_request_tmp"

), macro as (
    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_github/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_github/macros/).

        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    base_label
    
 , 
    cast(null as TEXT) as 
    
    base_ref
    
 , 
    cast(null as integer) as 
    
    base_repo_id
    
 , 
    cast(null as TEXT) as 
    
    base_sha
    
 , 
    cast(null as integer) as 
    
    base_user_id
    
 , 
    cast(null as TEXT) as 
    
    head_label
    
 , 
    cast(null as TEXT) as 
    
    head_ref
    
 , 
    cast(null as integer) as 
    
    head_repo_id
    
 , 
    cast(null as TEXT) as 
    
    head_sha
    
 , 
    cast(null as integer) as 
    
    head_user_id
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    issue_id
    
 , 
    cast(null as TEXT) as 
    
    merge_commit_sha
    
 


        
, 'github' || '.'|| 'github_integration_tests_1' as source_relation


    from pull_request

), fields as (

    select
        source_relation,
        id as pull_request_id,
        issue_id,
        head_repo_id,
        head_user_id
    from macro
)

select *
from fields
