with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        updated_at
,        last_name
,        email
,        status
,        country
    from source
)
select * from renamed
