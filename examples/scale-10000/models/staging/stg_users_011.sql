with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        last_name
,        first_name
,        created_at
,        updated_at
,        signup_source
,        status
,        country
    from source
)
select * from renamed
