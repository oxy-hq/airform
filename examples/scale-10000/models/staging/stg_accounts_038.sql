with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        region
,        company_size
,        created_at
,        industry
,        status
,        mrr
,        account_name
    from source
)
select * from renamed
