with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        shipping_method
,        status
,        total_amount
,        account_id
,        user_id
,        discount
    from source
)
select * from renamed
