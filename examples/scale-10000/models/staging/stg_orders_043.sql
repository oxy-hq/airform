with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        discount
,        shipping_method
,        order_date
,        status
,        tax
    from source
)
select * from renamed
