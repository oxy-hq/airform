with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        total_amount
,        order_date
,        shipping_method
    from source
)
select * from renamed
