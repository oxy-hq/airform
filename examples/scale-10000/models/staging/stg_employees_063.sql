with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        manager_id
,        email
,        department_id
,        hire_date
    from source
)
select * from renamed
