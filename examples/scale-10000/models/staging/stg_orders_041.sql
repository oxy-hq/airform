with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        status
,        shipping_method
,        total_amount
,        discount
,        currency
,        tax
,        account_id
    from source
)
select * from renamed
