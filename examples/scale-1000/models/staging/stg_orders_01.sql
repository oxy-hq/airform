with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        id as order_id
,        shipping_method
,        tax
,        account_id
,        total_amount
,        currency
,        order_date
    from source
)

select * from renamed
