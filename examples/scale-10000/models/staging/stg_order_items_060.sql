with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        status
,        order_id
,        sku
,        quantity
    from source
)
select * from renamed
