with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        region
,        company_size
,        industry
,        account_name
,        created_at
    from source
)
select * from renamed
