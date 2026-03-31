with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        status
,        first_name
,        country
,        last_name
,        email
,        updated_at
    from source
)
select * from renamed
