with base as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__charge_tmp"
),

fields as (

    select
        
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as integer) as 
    
    address_id
    
 , 
    cast(null as integer) as 
    
    customer_id
    
 , 
    cast(null as TEXT) as 
    
    customer_hash
    
 , 
    cast(null as TEXT) as 
    
    note
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as timestamp) as 
    
    processed_at
    
 , 
    cast(null as timestamp) as 
    
    scheduled_at
    
 , 
    cast(null as integer) as 
    
    orders_count
    
 , 
    cast(null as integer) as 
    
    external_order_id_ecommerce
    
 , 
    cast(null as float) as 
    
    subtotal_price
    
 , 
    cast(null as TEXT) as 
    
    tags
    
 , 
    cast(null as float) as 
    
    tax_lines
    
 , 
    cast(null as float) as 
    
    total_discounts
    
 , 
    cast(null as float) as 
    
    total_line_items_price
    
 , 
    cast(null as float) as 
    
    total_price
    
 , 
    cast(null as float) as 
    
    total_tax
    
 , 
    cast(null as float) as 
    
    total_weight_grams
    
 , 
    cast(null as TEXT) as 
    
    type
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as float) as 
    
    total_refunds
    
 , 
    cast(null as TEXT) as 
    
    external_transaction_id_payment_processor
    
 , 
    cast(null as TEXT) as 
    
    email
    
 , 
    cast(null as TEXT) as 
    
    payment_processor
    
 , 
    cast(null as boolean) as 
    
    has_uncommitted_changes
    
 , 
    cast(null as timestamp) as 
    
    retry_date
    
 , 
    cast(null as TEXT) as 
    
    error_type
    
 , 
    cast(null as TEXT) as 
    
    error
    
 , 
    cast(null as integer) as 
    
    charge_attempts
    
 , 
    cast(null as TEXT) as 
    
    external_variant_id_not_found
    
 , 
    cast(null as TEXT) as 
    
    client_details_browser_ip
    
 , 
    cast(null as TEXT) as 
    
    client_details_user_agent
    
 


        
, 'recharge' || '.'|| 'recharge_integration_tests_03' as source_relation

    from base
),

final as (

    select
        source_relation,
        id as charge_id,
        customer_id,
        customer_hash,
        email,
        cast(created_at as timestamp) as charge_created_at,
        type as charge_type,
        status as charge_status,
        cast(updated_at as timestamp) as charge_updated_at,
        note,
        subtotal_price,
        tax_lines,
        total_discounts,
        total_line_items_price,
        total_tax,
        cast(total_price as float) as total_price,
        total_refunds,
        total_weight_grams,
        cast(scheduled_at as timestamp) as charge_scheduled_at,
        cast(processed_at as timestamp) as charge_processed_at,
        payment_processor,
        external_transaction_id_payment_processor,
        external_order_id_ecommerce,
        orders_count,
        has_uncommitted_changes,
        cast(retry_date as timestamp) as retry_date,
        error_type,
        charge_attempts as times_retried,
        address_id,
        client_details_browser_ip,
        client_details_user_agent,
        tags,
        error,
        external_variant_id_not_found,
        _fivetran_deleted

        





    from fields
)

select *
from final
