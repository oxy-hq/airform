with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__order_item_promotion_id_base"
),

fields as (

    select
        
    cast(null as TEXT) as 
    
    amazon_order_id
    
 , 
    cast(null as TEXT) as 
    
    order_item_id
    
 , 
    cast(null as TEXT) as 
    
    promotion_id
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        amazon_order_id,
        order_item_id,
        promotion_id
    from fields
)

select *
from final
