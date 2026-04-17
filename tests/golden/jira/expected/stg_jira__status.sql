with base as (

    select * 
    from "jira"."main_jira_source"."stg_jira__status_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    description
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as integer) as 
    
    status_category_id
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        description as status_description,
        id as status_id,
        name as status_name,
        status_category_id,
        _fivetran_synced
    from fields
)

select * 
from final
