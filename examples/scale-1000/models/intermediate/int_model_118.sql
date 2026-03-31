with source as (
    select * from {{ ref('stg_orders_08') }}
),

final as (
    select
        warehouse_name,
        count(*) as record_count,
        sum(cast(warehouse_id as int)) as total_warehouse_id
    from source
    group by warehouse_name
)

select * from final
