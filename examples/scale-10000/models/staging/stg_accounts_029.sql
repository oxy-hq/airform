with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        owner_id
,        company_size
,        account_name
,        created_at
,        region
,        industry
    from source
)
select * from renamed
