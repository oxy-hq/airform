with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        signup_source
,        last_name
,        created_at
,        status
,        email
,        updated_at
,        country
    from source
)
select * from renamed
