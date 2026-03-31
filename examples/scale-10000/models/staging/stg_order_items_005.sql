with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        sku
,        status
,        unit_price
,        total_price
,        product_id
,        order_id
,        discount
    from source
)
select * from renamed
