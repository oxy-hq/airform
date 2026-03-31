with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        status
,        order_id
,        shipped_at
,        sku
    from source
)
select * from renamed
