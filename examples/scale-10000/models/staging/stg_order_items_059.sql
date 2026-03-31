with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        total_price
,        order_id
,        shipped_at
,        unit_price
,        sku
,        product_id
    from source
)
select * from renamed
