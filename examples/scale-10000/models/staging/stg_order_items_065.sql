with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        discount
,        shipped_at
,        status
,        sku
,        unit_price
,        quantity
    from source
)
select * from renamed
