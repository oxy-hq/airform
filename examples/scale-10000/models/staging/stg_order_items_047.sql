with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        discount
,        quantity
,        total_price
,        product_id
,        sku
,        unit_price
    from source
)
select * from renamed
