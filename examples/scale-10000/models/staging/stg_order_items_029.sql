with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),
renamed as (
    select
        id as order_item_id
,        product_id
,        discount
,        total_price
,        status
    from source
)
select * from renamed
