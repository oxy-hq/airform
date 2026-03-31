with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        status
,        owner_id
,        region
,        industry
,        created_at
    from source
)
select * from renamed
