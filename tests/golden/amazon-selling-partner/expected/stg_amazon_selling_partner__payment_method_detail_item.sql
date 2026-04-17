with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__payment_method_detail_item_base"
),

fields as (

    select
        
    cast(null as TEXT) as 
    
    amazon_order_id
    
 , 
    cast(null as TEXT) as 
    
    method
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        amazon_order_id,
        method
    from fields
)

select *
from final
