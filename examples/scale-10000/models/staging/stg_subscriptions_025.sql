with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        end_date
,        start_date
,        interval_months
,        currency
,        auto_renew
    from source
)
select * from renamed
