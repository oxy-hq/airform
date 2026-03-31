with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        product_id
,        total_price
,        unit_price
,        sku
,        order_id
,        status
,        shipped_at
    from source
)
select * from renamed
