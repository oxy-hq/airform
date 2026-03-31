with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        account_id
,        tax
,        discount
,        shipping_method
,        order_date
    from source
)
select * from renamed
