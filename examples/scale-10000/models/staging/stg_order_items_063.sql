with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        product_id
,        shipped_at
,        total_price
    from source
)
select * from renamed
