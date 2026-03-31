with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        industry
,        account_name
,        owner_id
,        company_size
,        mrr
,        created_at
    from source
)
select * from renamed
