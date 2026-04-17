with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__vendors_tmp"

),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    altname
    
 , 
    cast(null as integer) as 
    
    category
    
 , 
    cast(null as TEXT) as 
    
    companyname
    
 , 
    cast(null as timestamp) as 
    
    datecreated
    
 , 
    cast(null as TEXT) as 
    
    entityid
    
 , 
    cast(null as integer) as 
    
    id
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as vendor_id,
        entityid as entity_id,
        altname as alt_name,
        companyname as company_name,
        datecreated as create_date_at,
        category as vendor_category_id

        --The below macro adds the fields defined within your vendors_pass_through_columns variable into the staging model
        







    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
