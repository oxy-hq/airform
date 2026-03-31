with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        email
,        title
,        last_name
,        status
,        department_id
,        manager_id
    from source
)
select * from renamed
