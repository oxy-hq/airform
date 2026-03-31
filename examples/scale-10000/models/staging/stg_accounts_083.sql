with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        company_size
,        owner_id
,        mrr
    from source
)
select * from renamed
