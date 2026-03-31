with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        currency
,        tax
,        user_id
,        order_date
,        shipping_method
,        total_amount
    from source
)
select * from renamed
