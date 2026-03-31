with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        status
,        end_date
,        interval_months
,        start_date
,        auto_renew
,        currency
    from source
)
select * from renamed
