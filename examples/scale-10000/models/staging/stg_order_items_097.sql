with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        shipped_at
,        sku
,        status
,        product_id
,        total_price
,        quantity
    from source
)
select * from renamed
