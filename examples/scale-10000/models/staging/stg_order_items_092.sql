with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        unit_price
,        shipped_at
,        product_id
,        sku
,        order_id
,        discount
,        total_price
    from source
)
select * from renamed
