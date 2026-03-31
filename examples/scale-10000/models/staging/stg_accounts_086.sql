with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        created_at
,        industry
,        company_size
,        status
,        mrr
,        account_name
    from source
)
select * from renamed
