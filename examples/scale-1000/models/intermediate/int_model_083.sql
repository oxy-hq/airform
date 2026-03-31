with source as (
    select * from {{ ref('stg_support_tickets_03') }}
),

final as (
    select
        *,
        row_number() over (partition by account_id order by subscription_id) as row_num
    from source
)

select * from final
