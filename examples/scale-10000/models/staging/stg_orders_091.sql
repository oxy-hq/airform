with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        user_id
,        discount
,        currency
,        total_amount
,        account_id
,        order_date
    from source
)
select * from renamed
