with issue_comment as (

    select *
    from "github"."main_github_source"."stg_github__issue_comment_tmp"

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
    
    created_at
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    issue_id
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as integer) as 
    
    user_id
    
 


        
, 'github' || '.'|| 'github_integration_tests_1' as source_relation


    from issue_comment

), fields as (

    select
        source_relation,
        id as issue_comment_id,
        issue_id,
        user_id,
        created_at

    from macro
)

select *
from fields
