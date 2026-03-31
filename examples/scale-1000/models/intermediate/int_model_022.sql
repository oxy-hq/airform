with source as (
    select * from {{ ref('stg_subscriptions_02') }}
),

final as (
    select
        account_name,
        count(*) as record_count,
        sum(cast(account_id as int)) as total_account_id
    from source
    group by account_name
)

select * from final
