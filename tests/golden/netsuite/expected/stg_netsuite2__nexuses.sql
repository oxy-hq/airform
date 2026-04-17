with base as (

    select *
    from "netsuite"."main_netsuite_source"."stg_netsuite2__nexuses_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    country
    
 , 
    cast(null as TEXT) as 
    
    description
    
 , 
    cast(null as TEXT) as 
    
    state
    
 , 
    cast(null as integer) as 
    
    taxagency
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as nexus_id,
        country,
        description,
        state,
        taxagency as tax_agency_id

        --The below macro adds the fields defined within your nexuses_pass_through_columns variable into the staging model
        





    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
