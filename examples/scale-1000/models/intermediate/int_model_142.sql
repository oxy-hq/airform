with source as (
    select * from {{ ref('stg_channels_02') }}
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
