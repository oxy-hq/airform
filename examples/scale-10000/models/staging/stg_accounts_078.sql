with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        company_size
,        status
,        plan_type
,        created_at
    from source
)
select * from renamed
