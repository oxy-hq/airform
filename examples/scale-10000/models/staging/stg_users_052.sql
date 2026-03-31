with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        status
,        country
,        created_at
,        updated_at
,        first_name
    from source
)
select * from renamed
