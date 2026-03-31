with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        hire_date
,        department_id
,        email
,        title
    from source
)
select * from renamed
