with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        shipping_method
,        account_id
,        currency
,        user_id
,        tax
,        total_amount
,        status
    from source
)
select * from renamed
