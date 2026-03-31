with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        total_amount
,        order_date
,        account_id
,        status
,        user_id
,        discount
,        currency
    from source
)
select * from renamed
