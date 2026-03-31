with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        sku
,        unit_price
,        status
,        order_id
,        total_price
    from source
)
select * from renamed
