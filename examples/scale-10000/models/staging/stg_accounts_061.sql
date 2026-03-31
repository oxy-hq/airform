with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        company_size
,        region
,        owner_id
,        industry
,        status
    from source
)
select * from renamed
