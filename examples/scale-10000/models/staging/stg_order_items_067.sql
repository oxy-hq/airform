with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        unit_price
,        sku
,        total_price
,        quantity
,        order_id
    from source
)
select * from renamed
