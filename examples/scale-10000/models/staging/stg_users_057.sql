with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        status
,        created_at
,        email
,        signup_source
,        first_name
,        updated_at
,        last_name
    from source
)
select * from renamed
