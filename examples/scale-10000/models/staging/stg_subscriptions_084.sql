with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        interval_months
,        plan_id
,        currency
,        auto_renew
,        amount
    from source
)
select * from renamed
