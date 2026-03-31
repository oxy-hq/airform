with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        currency
,        status
,        account_id
,        user_id
,        tax
,        discount
,        shipping_method
    from source
)
select * from renamed
