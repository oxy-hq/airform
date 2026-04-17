with base as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__customer_tmp"
),

fields as (

    select
        
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    external_customer_id_ecommerce
    
 , 
    cast(null as TEXT) as 
    
    email
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as timestamp) as 
    
    first_charge_processed_at
    
 , 
    cast(null as TEXT) as 
    
    first_name
    
 , 
    cast(null as TEXT) as 
    
    last_name
    
 , 
    cast(null as integer) as 
    
    subscriptions_active_count
    
 , 
    cast(null as integer) as 
    
    subscriptions_total_count
    
 , 
    cast(null as boolean) as 
    
    has_valid_payment_method
    
 , 
    cast(null as boolean) as 
    
    has_payment_method_in_dunning
    
 , 
    cast(null as boolean) as 
    
    tax_exempt
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as TEXT) as 
    
    billing_first_name
    
 , 
    cast(null as TEXT) as 
    
    billing_last_name
    
 , 
    cast(null as TEXT) as 
    
    billing_company
    
 , 
    cast(null as TEXT) as 
    
    billing_city
    
 , 
    cast(null as TEXT) as 
    
    billing_country
    
 , 
    cast(null as TEXT) as customer_hash 


        
, 'recharge' || '.'|| 'recharge_integration_tests_03' as source_relation

    from base
),

final as (

    select
        source_relation,
        id as customer_id,
        customer_hash,
        external_customer_id_ecommerce,
        email,
        first_name,
        last_name,
        cast(created_at as timestamp) as customer_created_at,
        cast(updated_at as timestamp) as customer_updated_at,
        cast(first_charge_processed_at as timestamp) as first_charge_processed_at,
        subscriptions_active_count,
        subscriptions_total_count,
        has_valid_payment_method,
        has_payment_method_in_dunning,
        tax_exempt,
        billing_first_name,
        billing_last_name,
        billing_company,
        billing_city,
        billing_country,
        _fivetran_deleted
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
