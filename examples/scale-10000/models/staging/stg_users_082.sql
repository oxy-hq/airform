with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        status
,        email
,        signup_source
,        created_at
,        first_name
,        country
,        updated_at
    from source
)
select * from renamed
