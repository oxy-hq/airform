with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),

renamed as (
    select
        id as subscription_id
,        account_id
,        interval_months
,        amount
,        start_date
,        auto_renew
,        end_date
,        plan_id
    from source
)

select * from renamed
