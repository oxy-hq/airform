with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        last_name
,        country
,        created_at
,        updated_at
,        first_name
,        status
,        email
    from source
)
select * from renamed
