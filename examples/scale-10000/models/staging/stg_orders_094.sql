with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        total_amount
,        status
,        shipping_method
,        tax
    from source
)
select * from renamed
