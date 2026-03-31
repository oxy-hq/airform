with source as (
    select * from {{ ref('stg_events_01') }}
),

final as (
    select
        *,
        row_number() over (partition by product_name order by product_id) as row_num
    from source
)

select * from final
