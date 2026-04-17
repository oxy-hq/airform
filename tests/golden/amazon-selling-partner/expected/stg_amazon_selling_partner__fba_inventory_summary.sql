with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__fba_inventory_summary_base"
),

fields as (

    select
        
    cast(null as TEXT) as 
    
    _fivetran_id
    
 , 
    cast(null as TEXT) as 
    
    asin
    
 , 
    cast(null as integer) as 
    
    carrier_damaged_quantity
    
 , 
    cast(null as TEXT) as 
    
    condition
    
 , 
    cast(null as integer) as 
    
    customer_damaged_quantity
    
 , 
    cast(null as integer) as 
    
    defective_quantity
    
 , 
    cast(null as integer) as 
    
    distributor_damaged_quantity
    
 , 
    cast(null as integer) as 
    
    expired_quantity
    
 , 
    cast(null as integer) as 
    
    fc_processing_quantity
    
 , 
    cast(null as TEXT) as 
    
    fn_sku
    
 , 
    cast(null as integer) as 
    
    fulfillable_quantity
    
 , 
    cast(null as TEXT) as 
    
    granularity_id
    
 , 
    cast(null as TEXT) as 
    
    granularity_type
    
 , 
    cast(null as integer) as 
    
    inbound_shipped_quantity
    
 , 
    cast(null as integer) as 
    
    inbound_receiving_quantity
    
 , 
    cast(null as integer) as 
    
    inbound_working_quantity
    
 , 
    cast(null as timestamp) as 
    
    last_updated_time
    
 , 
    cast(null as integer) as 
    
    pending_customer_order_quantity
    
 , 
    cast(null as integer) as 
    
    pending_transshipment_quantity
    
 , 
    cast(null as TEXT) as 
    
    product_name
    
 , 
    cast(null as TEXT) as 
    
    seller_sku
    
 , 
    cast(null as integer) as 
    
    total_quantity
    
 , 
    cast(null as integer) as 
    
    total_researching_quantity
    
 , 
    cast(null as integer) as 
    
    total_reserved_quantity
    
 , 
    cast(null as integer) as 
    
    total_unfulfillable_quantity
    
 , 
    cast(null as integer) as 
    
    warehouse_damaged_quantity
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_id as inventory_summary_id,
        cast(asin as TEXT) as asin,
        fn_sku,
        seller_sku,
        product_name,
        condition,
        last_updated_time as last_updated_at,
        total_quantity,
        total_researching_quantity,
        total_reserved_quantity,
        fulfillable_quantity,
        fulfillable_quantity as fullfillable_quantity, -- Typo kept for backward compatibility. Will be removed in March 2026
        total_unfulfillable_quantity,
        pending_customer_order_quantity,
        pending_transshipment_quantity,
        fc_processing_quantity,
        inbound_shipped_quantity,
        inbound_shipped_quantity as inblound_shipped_quantity, -- Typo kept for backward compatibility. Will be removed in March 2026
        inbound_receiving_quantity,
        inbound_working_quantity,
        warehouse_damaged_quantity,
        carrier_damaged_quantity,
        customer_damaged_quantity,
        defective_quantity,
        distributor_damaged_quantity,
        expired_quantity,
        granularity_id,
        granularity_type

    from fields
)

select *
from final
