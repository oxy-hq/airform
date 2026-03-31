with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        order_id
,        sku
,        total_price
,        quantity
,        shipped_at
    from source
)
select * from renamed
