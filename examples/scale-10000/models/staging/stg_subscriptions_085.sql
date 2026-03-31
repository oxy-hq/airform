with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        interval_months
,        amount
,        start_date
,        auto_renew
,        end_date
    from source
)
select * from renamed
