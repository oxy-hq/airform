with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        status
,        shipping_method
,        currency
,        account_id
,        discount
,        tax
,        total_amount
    from source
)
select * from renamed
