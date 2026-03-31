with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        interval_months
,        amount
,        end_date
,        account_id
,        status
,        start_date
    from source
)
select * from renamed
