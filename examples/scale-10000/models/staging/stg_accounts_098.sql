with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        owner_id
,        status
,        created_at
,        plan_type
    from source
)
select * from renamed
