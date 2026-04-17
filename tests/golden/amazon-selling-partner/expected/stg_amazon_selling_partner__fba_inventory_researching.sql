with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__fba_inventory_researching_base"
),

fields as (

    select
        
    cast(null as TEXT) as 
    
    inventory_summary_id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as integer) as 
    
    quantity
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        inventory_summary_id,
        name,
        quantity
    from fields
)

select *
from final
