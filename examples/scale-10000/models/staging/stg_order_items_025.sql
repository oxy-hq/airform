with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        total_price
,        unit_price
,        discount
,        product_id
,        sku
    from source
)
select * from renamed
