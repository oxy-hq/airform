with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        total_amount
,        account_id
,        shipping_method
,        user_id
,        discount
,        currency
    from source
)
select * from renamed
