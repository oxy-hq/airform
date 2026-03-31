with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        currency
,        discount
,        total_amount
,        shipping_method
    from source
)
select * from renamed
