with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        shipped_at
,        sku
,        total_price
,        quantity
,        unit_price
,        product_id
    from source
)
select * from renamed
