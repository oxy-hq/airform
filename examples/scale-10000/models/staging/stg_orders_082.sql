with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        account_id
,        tax
,        shipping_method
,        status
,        user_id
,        total_amount
    from source
)
select * from renamed
