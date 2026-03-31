with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        region
,        plan_type
,        status
    from source
)
select * from renamed
