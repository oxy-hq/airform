with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        currency
,        amount
,        interval_months
,        auto_renew
    from source
)
select * from renamed
