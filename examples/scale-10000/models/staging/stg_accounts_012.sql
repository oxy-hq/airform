with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        created_at
,        account_name
,        region
    from source
)
select * from renamed
