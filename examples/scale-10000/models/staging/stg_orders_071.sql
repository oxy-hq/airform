with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        status
,        user_id
,        tax
,        account_id
,        order_date
    from source
)
select * from renamed
