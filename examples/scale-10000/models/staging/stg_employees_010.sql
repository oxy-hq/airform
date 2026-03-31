with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        manager_id
,        department_id
,        email
,        first_name
,        salary
    from source
)
select * from renamed
