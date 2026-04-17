with base as (

    select * 
    from "jira"."main_jira_source"."stg_jira__issue_link_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    issue_id
    
 , 
    cast(null as integer) as 
    
    related_issue_id
    
 , 
    cast(null as TEXT) as 
    
    relationship
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        issue_id,
        related_issue_id,
        relationship,
        _fivetran_synced 
    from fields
)

select * 
from final
