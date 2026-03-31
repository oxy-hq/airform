with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        manager_id
,        title
,        salary
,        last_name
,        email
,        first_name
,        status
    from source
)
select * from renamed
