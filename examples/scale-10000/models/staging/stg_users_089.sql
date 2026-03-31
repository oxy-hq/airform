with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        email
,        last_name
,        created_at
,        status
,        signup_source
,        country
    from source
)
select * from renamed
