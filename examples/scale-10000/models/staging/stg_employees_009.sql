with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        last_name
,        status
,        salary
,        manager_id
,        department_id
,        email
    from source
)
select * from renamed
