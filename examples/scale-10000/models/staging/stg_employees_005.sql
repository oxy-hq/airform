with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        last_name
,        email
,        manager_id
,        status
,        title
    from source
)
select * from renamed
