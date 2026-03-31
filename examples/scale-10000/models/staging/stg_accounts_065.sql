with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        industry
,        company_size
,        region
    from source
)
select * from renamed
