with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        total_amount
,        currency
,        tax
,        shipping_method
,        order_date
,        discount
,        account_id
    from source
)
select * from renamed
