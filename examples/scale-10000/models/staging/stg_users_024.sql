with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        country
,        account_id
,        last_name
,        email
,        created_at
,        status
,        updated_at
    from source
)
select * from renamed
