with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        unit_price
,        quantity
,        product_id
,        order_id
,        sku
,        discount
    from source
)
select * from renamed
