with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        department_id
,        manager_id
,        hire_date
,        salary
    from source
)
select * from renamed
