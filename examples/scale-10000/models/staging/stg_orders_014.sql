with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        user_id
,        status
,        discount
,        shipping_method
    from source
)
select * from renamed
