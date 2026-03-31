with users as (
    select * from {{ ref('stg_users') }}
),

final as (
    select
        user_id,
        created_at,
        status,
        signup_source,
        cast(created_at as date) as signup_date,
        case
            when created_at < '2024-04-01' then 'Q1_2024'
            when created_at < '2024-07-01' then 'Q2_2024'
            when created_at < '2024-10-01' then 'Q3_2024'
            else 'Q4_2024'
        end as signup_quarter
    from users
)

select * from final
