with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        status
,        email
,        updated_at
,        signup_source
,        created_at
,        country
    from source
)
select * from renamed
