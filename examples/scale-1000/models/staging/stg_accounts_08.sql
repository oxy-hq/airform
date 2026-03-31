with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),

renamed as (
    select
        id as account_id
,        status
,        plan_type
,        industry
,        region
,        owner_id
    from source
)

select * from renamed
