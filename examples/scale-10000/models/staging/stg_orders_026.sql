with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        shipping_method
,        status
,        account_id
,        currency
    from source
)
select * from renamed
