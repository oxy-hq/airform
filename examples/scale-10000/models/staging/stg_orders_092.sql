with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        tax
,        status
,        account_id
,        user_id
,        discount
,        shipping_method
,        currency
    from source
)
select * from renamed
