with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),

renamed as (
    select
        id as order_item_id
,        status
,        quantity
,        sku
,        total_price
,        shipped_at
    from source
)

select * from renamed
