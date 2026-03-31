with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        updated_at
,        signup_source
,        email
,        first_name
,        status
,        created_at
,        last_name
    from source
)
select * from renamed
