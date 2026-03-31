with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        shipping_method
,        discount
,        total_amount
,        tax
,        currency
,        status
,        user_id
    from source
)
select * from renamed
