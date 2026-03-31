with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        account_id
,        last_name
,        email
,        signup_source
,        updated_at
,        created_at
    from source
)
select * from renamed
