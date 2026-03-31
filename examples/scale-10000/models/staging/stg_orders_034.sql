with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        account_id
,        status
,        tax
,        shipping_method
,        total_amount
,        currency
    from source
)
select * from renamed
