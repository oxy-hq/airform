with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),

renamed as (
    select
        id as order_item_id
,        order_id
,        total_price
,        shipped_at
,        unit_price
,        product_id
,        discount
,        status
    from source
)

select * from renamed
