with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        discount
,        product_id
,        total_price
,        sku
,        status
,        unit_price
,        shipped_at
    from source
)
select * from renamed
