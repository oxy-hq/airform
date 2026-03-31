with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        account_name
,        created_at
,        industry
,        owner_id
,        company_size
    from source
)
select * from renamed
