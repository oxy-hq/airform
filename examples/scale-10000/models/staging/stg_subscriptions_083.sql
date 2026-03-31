with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        status
,        amount
,        account_id
,        start_date
,        interval_months
,        auto_renew
    from source
)
select * from renamed
