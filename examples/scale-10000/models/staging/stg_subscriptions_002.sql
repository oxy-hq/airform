with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        auto_renew
,        end_date
,        interval_months
,        currency
    from source
)
select * from renamed
