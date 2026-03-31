with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        currency
,        tax
,        shipping_method
,        total_amount
,        order_date
,        account_id
,        user_id
    from source
)
select * from renamed
