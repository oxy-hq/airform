with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        account_name
,        plan_type
,        created_at
,        company_size
,        mrr
,        status
    from source
)
select * from renamed
