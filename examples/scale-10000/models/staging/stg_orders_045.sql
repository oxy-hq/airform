with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        status
,        shipping_method
,        account_id
,        currency
,        tax
    from source
)
select * from renamed
