with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),

renamed as (
    select
        id as account_id
,        plan_type
,        company_size
,        created_at
,        status
,        mrr
,        region
,        owner_id
    from source
)

select * from renamed
