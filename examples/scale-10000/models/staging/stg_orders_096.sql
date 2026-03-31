with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        account_id
,        order_date
,        tax
,        total_amount
,        shipping_method
,        user_id
,        currency
    from source
)
select * from renamed
