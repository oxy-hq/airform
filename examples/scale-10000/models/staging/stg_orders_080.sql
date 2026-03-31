with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        total_amount
,        order_date
,        discount
,        shipping_method
,        status
    from source
)
select * from renamed
