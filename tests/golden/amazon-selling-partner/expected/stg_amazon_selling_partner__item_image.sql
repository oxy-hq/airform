with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__item_image_base"
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
    
    height
    
 , 
    cast(null as TEXT) as 
    
    link
    
 , 
    cast(null as TEXT) as 
    
    marketplace_id
    
 , 
    cast(null as TEXT) as 
    
    variant
    
 , 
    cast(null as integer) as 
    
    width
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_synced,
        cast(asin as TEXT) as asin,
        height,
        link,
        marketplace_id,
        upper(variant) as variant,
        width
    from fields
)

select *
from final
