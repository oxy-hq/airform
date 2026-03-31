with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        industry
,        company_size
,        owner_id
,        account_name
,        mrr
,        region
,        status
    from source
)
select * from renamed
