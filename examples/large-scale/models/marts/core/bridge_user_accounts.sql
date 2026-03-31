with users as (
    select * from {{ ref('stg_users') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

final as (
    select
        users.user_id,
        users.account_id,
        accounts.account_name,
        users.status as user_status,
        accounts.status as account_status,
        users.created_at as user_created_at,
        accounts.created_at as account_created_at
    from users
    left join accounts on users.account_id = accounts.account_id
)

select * from final
