with users as (
    select * from {{ ref('stg_users') }}
),

final as (
    select
        account_id,
        count(*) as total_users,
        sum(case when status = 'active' then 1 else 0 end) as active_users,
        sum(case when status = 'churned' then 1 else 0 end) as churned_users,
        sum(case when status = 'trial' then 1 else 0 end) as trial_users,
        min(created_at) as first_user_at,
        max(created_at) as last_user_at
    from users
    group by account_id
)

select * from final
