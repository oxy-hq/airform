with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        status
,        product_id
,        quantity
,        order_id
,        discount
    from source
)
select * from renamed
