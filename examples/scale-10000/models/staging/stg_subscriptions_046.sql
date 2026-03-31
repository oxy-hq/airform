with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        start_date
,        currency
,        auto_renew
,        amount
    from source
)
select * from renamed
