with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        status
,        product_id
,        total_price
,        discount
,        sku
,        shipped_at
,        unit_price
    from source
)
select * from renamed
