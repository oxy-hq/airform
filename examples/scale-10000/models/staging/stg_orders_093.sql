with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        tax
,        account_id
,        user_id
,        discount
,        currency
,        total_amount
,        shipping_method
    from source
)
select * from renamed
