with source as (
    select * from {{ ref('stg_departments_07') }}
),

final as (
    select
        *,
        row_number() over (partition by user_id order by session_id) as row_num
    from source
)

select * from final
