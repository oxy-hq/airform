with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        status
,        email
,        salary
,        manager_id
,        first_name
,        department_id
    from source
)
select * from renamed
