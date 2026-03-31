with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        created_at
,        region
,        status
    from source
)
select * from renamed
