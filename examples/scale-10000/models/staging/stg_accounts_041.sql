with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        region
,        account_name
,        company_size
,        status
    from source
)
select * from renamed
