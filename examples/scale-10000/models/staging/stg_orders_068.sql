with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        tax
,        status
,        currency
,        total_amount
,        discount
,        account_id
    from source
)
select * from renamed
