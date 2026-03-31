with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        discount
,        user_id
,        currency
,        shipping_method
,        account_id
,        status
    from source
)
select * from renamed
