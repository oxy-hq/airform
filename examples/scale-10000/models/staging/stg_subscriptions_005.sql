with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        interval_months
,        plan_id
,        status
,        account_id
,        currency
    from source
)
select * from renamed
