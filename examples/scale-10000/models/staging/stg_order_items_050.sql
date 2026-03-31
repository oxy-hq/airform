with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        sku
,        quantity
,        unit_price
,        shipped_at
,        total_price
,        discount
    from source
)
select * from renamed
