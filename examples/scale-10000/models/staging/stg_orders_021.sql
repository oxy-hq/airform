with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        status
,        user_id
,        shipping_method
,        currency
,        total_amount
,        discount
    from source
)
select * from renamed
