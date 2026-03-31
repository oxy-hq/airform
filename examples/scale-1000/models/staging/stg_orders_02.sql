with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        id as order_id
,        status
,        account_id
,        discount
    from source
)

select * from renamed
