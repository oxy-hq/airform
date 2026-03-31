with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        user_id
,        shipping_method
,        discount
,        total_amount
,        status
,        order_date
    from source
)
select * from renamed
