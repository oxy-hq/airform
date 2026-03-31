with source as (
    select * from {{ ref('stg_invoices_05') }}
),

final as (
    select
        *,
        row_number() over (partition by channel_name order by channel_id) as row_num
    from source
)

select * from final
