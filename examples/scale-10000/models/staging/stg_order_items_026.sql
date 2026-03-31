with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        sku
,        product_id
,        status
,        shipped_at
,        order_id
,        quantity
    from source
)
select * from renamed
