with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        last_name
,        status
,        updated_at
,        created_at
,        first_name
,        signup_source
,        country
    from source
)
select * from renamed
