with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        account_id
,        created_at
,        updated_at
,        first_name
,        email
    from source
)
select * from renamed
