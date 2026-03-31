with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        currency
,        total_amount
,        user_id
,        discount
,        account_id
    from source
)
select * from renamed
