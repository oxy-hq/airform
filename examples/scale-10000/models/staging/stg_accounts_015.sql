with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        mrr
,        company_size
,        owner_id
,        created_at
    from source
)
select * from renamed
