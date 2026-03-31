with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        updated_at
,        account_id
,        email
,        created_at
    from source
)
select * from renamed
