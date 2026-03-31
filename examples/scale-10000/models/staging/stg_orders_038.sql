with source as (
    select * from {{ source('raw', 'raw_orders') }}
),
renamed as (
    select
        id as order_id
,        account_id
,        tax
,        status
,        order_date
,        discount
    from source
)
select * from renamed
