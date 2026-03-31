with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        sku
,        order_id
,        status
    from source
)
select * from renamed
