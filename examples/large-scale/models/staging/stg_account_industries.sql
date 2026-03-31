with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),

final as (
    select
        id as account_id,
        industry,
        case
            when industry in ('technology') then 'tech'
            when industry in ('finance') then 'finserv'
            when industry in ('healthcare') then 'health'
            when industry in ('retail') then 'retail'
            else 'other'
        end as industry_vertical,
        company_size,
        case
            when company_size >= 500 then 'enterprise'
            when company_size >= 100 then 'mid_market'
            when company_size >= 25 then 'smb'
            else 'startup'
        end as company_segment
    from source
)

select * from final
