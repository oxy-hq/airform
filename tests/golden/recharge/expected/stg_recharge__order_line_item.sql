with base as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__order_line_item_tmp"
),

fields as (

    select
        
    cast(null as integer) as 
    
    order_id
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as integer) as 
    
    index
    
 , 
    cast(null as TEXT) as 
    
    variant_title
    
 , 
    cast(null as TEXT) as 
    
    title
    
 , 
    cast(null as integer) as 
    
    quantity
    
 , 
    cast(null as float) as 
    
    grams
    
 , 
    cast(null as float) as 
    
    total_price
    
 , 
    cast(null as float) as 
    
    unit_price
    
 , 
    cast(null as float) as 
    
    tax_due
    
 , 
    cast(null as boolean) as 
    
    taxable
    
 , 
    cast(null as float) as 
    
    taxable_amount
    
 , 
    cast(null as boolean) as 
    
    unit_price_includes_tax
    
 , 
    cast(null as TEXT) as 
    
    sku
    
 , 
    cast(null as integer) as 
    
    external_product_id_ecommerce
    
 , 
    cast(null as integer) as 
    
    external_variant_id_ecommerce
    
 , 
    cast(null as integer) as 
    
    purchase_item_id
    
 , 
    cast(null as TEXT) as 
    
    purchase_item_type
    
 


        
, 'recharge' || '.'|| 'recharge_integration_tests_03' as source_relation

    from base
),

final as (

    select
        source_relation,
        order_id,
        index,
        external_product_id_ecommerce,
        external_variant_id_ecommerce,
        title as order_line_item_title,
        variant_title as product_variant_title,
        sku,
        quantity,
        grams,
        cast(total_price as float) as total_price,
        unit_price,
        tax_due,
        taxable,
        taxable_amount,
        unit_price_includes_tax,
        purchase_item_id,
        purchase_item_type

        




    from fields
)

select *
from final
