with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        account_id
,        start_date
,        status
,        interval_months
,        currency
,        plan_id
    from source
)
select * from renamed
