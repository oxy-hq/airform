with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        status
,        discount
,        tax
,        shipping_method
    from source
)
select * from renamed
