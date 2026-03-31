with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        quantity
,        unit_price
,        order_id
,        sku
    from source
)
select * from renamed
