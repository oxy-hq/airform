with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        status
,        company_size
,        mrr
,        created_at
    from source
)
select * from renamed
