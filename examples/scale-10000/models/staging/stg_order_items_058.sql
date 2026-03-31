with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        quantity
,        unit_price
,        sku
,        status
,        shipped_at
,        discount
,        total_price
    from source
)
select * from renamed
