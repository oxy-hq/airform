with base as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__address_tmp"
),

fields as (

    select
        
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    customer_id
    
 , 
    cast(null as TEXT) as 
    
    first_name
    
 , 
    cast(null as TEXT) as 
    
    last_name
    
 , 
    cast(null as TEXT) as 
    
    address_1
    
 , 
    cast(null as TEXT) as 
    
    address_2
    
 , 
    cast(null as TEXT) as 
    
    city
    
 , 
    cast(null as TEXT) as 
    
    province
    
 , 
    cast(null as TEXT) as 
    
    country_code
    
 , 
    cast(null as TEXT) as 
    
    country
    
 , 
    cast(null as TEXT) as 
    
    zip
    
 , 
    cast(null as TEXT) as 
    
    company
    
 , 
    cast(null as TEXT) as 
    
    phone
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as TEXT) as 
    
    payment_method_id
    
 


        
, 'recharge' || '.'|| 'recharge_integration_tests_03' as source_relation

    from base
),

final as (

    select
        source_relation,
        id as address_id,
        customer_id,
        first_name,
        last_name,
        cast(created_at as timestamp) as address_created_at,
        cast(updated_at as timestamp) as address_updated_at,
        address_1 as address_line_1,
        address_2 as address_line_2,
        city,
        province,
        zip,
        country_code,
        country,
        company,
        phone,
        payment_method_id

        





    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
