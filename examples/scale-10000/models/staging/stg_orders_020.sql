with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        status
,        tax
,        account_id
,        total_amount
,        discount
,        order_date
,        user_id
    from source
)
select * from renamed
