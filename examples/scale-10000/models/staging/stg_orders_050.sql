with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        status
,        discount
,        order_date
,        user_id
,        account_id
,        total_amount
,        currency
    from source
)
select * from renamed
