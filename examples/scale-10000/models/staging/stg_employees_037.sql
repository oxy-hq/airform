with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        department_id
,        hire_date
,        manager_id
,        first_name
,        salary
    from source
)
select * from renamed
