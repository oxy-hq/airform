with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        currency
,        account_id
,        end_date
,        start_date
,        plan_id
,        interval_months
,        amount
    from source
)
select * from renamed
