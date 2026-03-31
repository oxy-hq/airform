with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),

renamed as (
    select
        id as subscription_id
,        status
,        currency
,        plan_id
    from source
)

select * from renamed
