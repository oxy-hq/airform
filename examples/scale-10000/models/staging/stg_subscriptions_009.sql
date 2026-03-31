with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        interval_months
,        status
,        plan_id
,        account_id
,        currency
    from source
)
select * from renamed
