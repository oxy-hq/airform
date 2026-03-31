with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        updated_at
,        status
,        account_id
,        created_at
,        email
    from source
)
select * from renamed
