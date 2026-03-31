with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        status
,        title
,        last_name
,        department_id
,        hire_date
,        manager_id
,        first_name
    from source
)
select * from renamed
