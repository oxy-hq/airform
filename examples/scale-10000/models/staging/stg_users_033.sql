with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        country
,        status
,        created_at
,        last_name
,        email
    from source
)
select * from renamed
