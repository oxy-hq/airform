with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        account_id
,        total_amount
,        shipping_method
,        currency
,        order_date
,        status
    from source
)
select * from renamed
