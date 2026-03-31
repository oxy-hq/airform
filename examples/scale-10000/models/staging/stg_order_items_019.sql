with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        order_id
,        product_id
,        unit_price
,        total_price
,        quantity
,        sku
    from source
)
select * from renamed
