with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        company_size
,        created_at
,        region
,        account_name
,        owner_id
    from source
)
select * from renamed
