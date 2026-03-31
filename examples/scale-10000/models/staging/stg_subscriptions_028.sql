with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        currency
,        end_date
,        amount
,        status
    from source
)
select * from renamed
