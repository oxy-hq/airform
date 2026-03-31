with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        account_id
,        start_date
,        auto_renew
,        interval_months
,        status
    from source
)
select * from renamed
