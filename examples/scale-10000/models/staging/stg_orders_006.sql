with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        currency
,        shipping_method
,        tax
,        order_date
,        discount
,        total_amount
,        user_id
    from source
)
select * from renamed
