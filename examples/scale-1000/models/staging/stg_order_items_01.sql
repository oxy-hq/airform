with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),

renamed as (
    select
        id as order_item_id
,        total_price
,        sku
,        discount
,        unit_price
,        status
,        order_id
,        product_id
    from source
)

select * from renamed
