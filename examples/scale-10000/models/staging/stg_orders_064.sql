with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        total_amount
,        status
,        discount
,        user_id
,        order_date
,        shipping_method
,        account_id
    from source
)
select * from renamed
