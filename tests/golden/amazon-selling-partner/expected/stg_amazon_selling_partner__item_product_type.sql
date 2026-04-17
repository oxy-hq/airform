with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__item_product_type_base"
),

fields as (

    select
        
    cast(null as TEXT) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    asin
    
 , 
    cast(null as TEXT) as 
    
    marketplace_id
    
 , 
    cast(null as TEXT) as 
    
    product_type
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_synced,
        cast(asin as TEXT) as asin,
        marketplace_id,
        product_type
    from fields
)

select *
from final
