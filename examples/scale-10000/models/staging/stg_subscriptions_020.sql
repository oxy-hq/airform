with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        status
,        plan_id
,        account_id
    from source
)
select * from renamed
