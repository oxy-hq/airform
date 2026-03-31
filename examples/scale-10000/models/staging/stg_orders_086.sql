with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        currency
,        account_id
,        order_date
,        user_id
,        status
,        shipping_method
    from source
)
select * from renamed
