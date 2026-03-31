with source as (
    select * from {{ ref('stg_accounts_06') }}
),

final as (
    select
        *,
        case
            when status = 'active' then 1
            when status = 'inactive' then 0
            else -1
        end as status_flag,
        coalesce(status, 'unknown') as status_clean
    from source
)

select * from final
