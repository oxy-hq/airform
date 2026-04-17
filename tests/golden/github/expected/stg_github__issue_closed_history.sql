with issue_closed_history as (

    select *
    from "github"."main_github_source"."stg_github__issue_closed_history_tmp"

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
    cast(null as integer) as 
    
    actor_id
    
 , 
    cast(null as boolean) as 
    
    closed
    
 , 
    cast(null as TEXT) as 
    
    commit_sha
    
 , 
    cast(null as integer) as 
    
    issue_id
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 


        
, 'github' || '.'|| 'github_integration_tests_1' as source_relation


    from issue_closed_history

), fields as (

    select
        source_relation,
        issue_id,
        cast(updated_at as timestamp) as updated_at,
        closed as is_closed

    from macro
)

select *
from fields
