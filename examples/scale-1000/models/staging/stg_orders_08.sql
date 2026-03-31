with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        id as order_id
,        discount
,        currency
,        account_id
,        shipping_method
,        user_id
,        status
,        total_amount
    from source
)

select * from renamed
