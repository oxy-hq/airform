with issue as (

    select *
    from "github"."main_github_source"."stg_github__issue_tmp"

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
    
    body
    
 , 
    cast(null as timestamp) as 
    
    closed_at
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as boolean) as 
    
    locked
    
 , 
    cast(null as integer) as 
    
    milestone_id
    
 , 
    cast(null as integer) as 
    
    number
    
 , 
    cast(null as boolean) as 
    
    pull_request
    
 , 
    cast(null as integer) as 
    
    repository_id
    
 , 
    cast(null as TEXT) as 
    
    state
    
 , 
    cast(null as TEXT) as 
    
    title
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as integer) as 
    
    user_id
    
 


        
, 'github' || '.'|| 'github_integration_tests_1' as source_relation


    from issue 

), fields as (

    select
        source_relation,
        id as issue_id,
        body,
        cast(closed_at as timestamp) as closed_at,
        cast(created_at as timestamp) as created_at,
        locked as is_locked,
        milestone_id,
        number as issue_number,
        pull_request as is_pull_request,
        repository_id,
        state,
        title,
        cast(updated_at as timestamp) as updated_at,
        user_id
    from macro
)

select *
from fields
