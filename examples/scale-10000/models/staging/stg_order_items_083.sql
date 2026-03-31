with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        quantity
,        order_id
,        discount
,        status
,        sku
,        shipped_at
    from source
)
select * from renamed
