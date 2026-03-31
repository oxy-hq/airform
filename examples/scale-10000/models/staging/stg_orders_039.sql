with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        user_id
,        currency
,        account_id
,        status
    from source
)
select * from renamed
