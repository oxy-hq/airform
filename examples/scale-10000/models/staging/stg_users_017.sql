with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        status
,        created_at
,        updated_at
,        account_id
    from source
)
select * from renamed
