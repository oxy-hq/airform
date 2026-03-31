with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        discount
,        tax
,        currency
,        total_amount
,        status
,        account_id
    from source
)
select * from renamed
