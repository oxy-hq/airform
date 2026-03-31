with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),

renamed as (
    select
        id as order_item_id
,        shipped_at
,        status
,        unit_price
,        total_price
,        sku
,        discount
,        quantity
    from source
)

select * from renamed
