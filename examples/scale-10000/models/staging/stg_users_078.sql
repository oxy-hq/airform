with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        email
,        updated_at
,        account_id
,        status
    from source
)
select * from renamed
