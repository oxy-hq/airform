with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        first_name
,        manager_id
,        salary
,        department_id
,        title
,        hire_date
,        last_name
    from source
)
select * from renamed
