with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        unit_price
,        shipped_at
,        quantity
,        product_id
,        total_price
,        order_id
    from source
)
select * from renamed
