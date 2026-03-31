with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        shipping_method
,        status
,        order_date
,        currency
    from source
)
select * from renamed
