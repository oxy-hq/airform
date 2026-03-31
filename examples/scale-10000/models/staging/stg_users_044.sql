with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        last_name
,        created_at
,        status
,        updated_at
    from source
)
select * from renamed
