with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        currency
,        account_id
,        shipping_method
,        user_id
,        tax
    from source
)
select * from renamed
