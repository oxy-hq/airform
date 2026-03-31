with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        status
,        order_date
,        account_id
,        discount
,        total_amount
,        tax
,        currency
    from source
)
select * from renamed
