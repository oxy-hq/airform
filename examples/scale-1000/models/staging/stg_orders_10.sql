with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        id as order_id
,        total_amount
,        tax
,        account_id
,        order_date
,        currency
    from source
)

select * from renamed
