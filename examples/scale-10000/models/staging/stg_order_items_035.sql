with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        status
,        sku
,        discount
,        total_price
,        product_id
,        order_id
,        unit_price
    from source
)
select * from renamed
