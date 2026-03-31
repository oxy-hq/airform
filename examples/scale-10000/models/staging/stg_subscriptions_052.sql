with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        plan_id
,        account_id
,        interval_months
,        end_date
,        amount
    from source
)
select * from renamed
