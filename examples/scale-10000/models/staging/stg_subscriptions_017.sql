with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        auto_renew
,        end_date
,        account_id
,        interval_months
,        currency
,        plan_id
,        status
    from source
)
select * from renamed
