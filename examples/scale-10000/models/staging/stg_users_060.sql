with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        country
,        first_name
,        created_at
,        updated_at
,        account_id
,        status
,        last_name
    from source
)
select * from renamed
