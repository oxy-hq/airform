with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        currency
,        shipping_method
,        user_id
,        status
,        account_id
,        total_amount
    from source
)
select * from renamed
