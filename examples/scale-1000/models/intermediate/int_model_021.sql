with a as (
    select * from {{ ref('stg_subscriptions_01') }}
),

b as (
    select * from {{ ref('stg_subscriptions_08') }}
),

final as (
    select
        a.user_id,
        a.account_id,
        a.email,
        b.page_view_id,
        b.session_id,
        b.user_id
    from a
    left join b on a.user_id = b.page_view_id
)

select * from final
