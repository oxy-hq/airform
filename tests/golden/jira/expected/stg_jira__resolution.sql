with base as (

    select * 
    from "jira"."main_jira_source"."stg_jira__resolution_tmp"
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
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        description as resolution_description,
        id as resolution_id,
        name as resolution_name,
        _fivetran_synced
    from fields
)

select * 
from final
