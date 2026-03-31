with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        account_id
,        end_date
,        currency
,        start_date
,        plan_id
    from source
)
select * from renamed
