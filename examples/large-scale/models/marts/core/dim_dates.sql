with date_spine as (
    select cast('2024-01-01' as date) as date_key
    union all select cast('2024-01-15' as date)
    union all select cast('2024-02-01' as date)
    union all select cast('2024-02-15' as date)
    union all select cast('2024-03-01' as date)
    union all select cast('2024-03-15' as date)
    union all select cast('2024-04-01' as date)
    union all select cast('2024-04-15' as date)
    union all select cast('2024-05-01' as date)
    union all select cast('2024-05-15' as date)
    union all select cast('2024-06-01' as date)
    union all select cast('2024-06-15' as date)
    union all select cast('2024-07-01' as date)
    union all select cast('2024-07-15' as date)
),

final as (
    select
        date_key,
        case
            when date_key < '2024-04-01' then 1
            when date_key < '2024-07-01' then 2
            when date_key < '2024-10-01' then 3
            else 4
        end as quarter_number,
        case
            when date_key < '2024-04-01' then 'Q1_2024'
            when date_key < '2024-07-01' then 'Q2_2024'
            when date_key < '2024-10-01' then 'Q3_2024'
            else 'Q4_2024'
        end as quarter_name,
        2024 as year_number
    from date_spine
)

select * from final
