with source as (
    select * from {{ ref('stg_order_items_06') }}
),

final as (
    select
        user_id,
        count(*) as record_count,
        sum(cast(event_id as int)) as total_event_id
    from source
    group by user_id
)

select * from final
