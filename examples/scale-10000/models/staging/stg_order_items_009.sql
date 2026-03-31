with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        quantity
,        discount
,        product_id
,        status
,        order_id
,        unit_price
    from source
)
select * from renamed
