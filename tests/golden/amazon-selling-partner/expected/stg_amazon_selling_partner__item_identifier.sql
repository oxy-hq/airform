with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__item_identifier_base"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    asin
    
 , 
    cast(null as integer) as 
    
    identifier
    
 , 
    cast(null as TEXT) as 
    
    identifier_type
    
 , 
    cast(null as TEXT) as 
    
    marketplace_id
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_synced,
        cast(asin as TEXT) as asin,
        identifier,
        identifier_type,
        marketplace_id
    from fields
)

select *
from final
