with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),

renamed as (
    select
        id as subscription_id
,        currency
,        plan_id
,        amount
,        auto_renew
,        status
,        interval_months
    from source
)

select * from renamed
