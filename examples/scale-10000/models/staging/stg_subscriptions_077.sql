with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        amount
,        status
,        interval_months
,        end_date
,        account_id
,        auto_renew
,        currency
    from source
)
select * from renamed
