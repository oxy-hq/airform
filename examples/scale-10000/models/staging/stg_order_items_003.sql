with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        order_id
,        product_id
,        quantity
,        total_price
,        unit_price
,        sku
,        discount
    from source
)
select * from renamed
