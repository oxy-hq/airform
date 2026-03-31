with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        email
,        account_id
,        status
,        updated_at
    from source
)
select * from renamed
