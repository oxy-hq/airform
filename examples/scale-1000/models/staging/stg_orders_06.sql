with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        id as order_id
,        tax
,        total_amount
,        discount
,        currency
,        user_id
,        status
    from source
)

select * from renamed
