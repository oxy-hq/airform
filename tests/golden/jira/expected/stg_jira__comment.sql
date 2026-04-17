with base as (

    select * 
    from "jira"."main_jira_source"."stg_jira__comment_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    author_id
    
 , 
    cast(null as TEXT) as 
    
    body
    
 , 
    cast(null as timestamp) as 
    
    created
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as boolean) as 
    
    is_public
    
 , 
    cast(null as integer) as 
    
    issue_id
    
 , 
    cast(null as TEXT) as 
    
    update_author_id
    
 , 
    cast(null as timestamp) as 
    
    updated
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        author_id as author_user_id,
        body,
        cast(created as timestamp) as created_at,
        id as comment_id,
        issue_id,
        is_public,
        update_author_id as last_update_user_id,
        cast(updated as timestamp) as last_updated_at,
        _fivetran_synced
    from fields
)

select * 
from final
