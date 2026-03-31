with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        order_date
,        total_amount
,        currency
,        shipping_method
,        user_id
    from source
)
select * from renamed
