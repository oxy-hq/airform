with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        email
,        first_name
,        created_at
,        last_name
,        status
    from source
)
select * from renamed
