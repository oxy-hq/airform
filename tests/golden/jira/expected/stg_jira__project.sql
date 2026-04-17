with base as (
    
    select *
    from "jira"."main_jira_source"."stg_jira__project_tmp"
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
    
    key
    
 , 
    cast(null as TEXT) as 
    
    lead_id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as integer) as 
    
    permission_scheme_id
    
 , 
    cast(null as integer) as 
    
    project_category_id
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base

),

final as (

    select
        source_relation,
        description as project_description,
        id as project_id,
        key as project_key,
        lead_id as project_lead_user_id,
        name as project_name,
        project_category_id,
        permission_scheme_id,
        _fivetran_synced
    from fields
)

select * 
from final
