with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        last_name
,        salary
,        first_name
,        department_id
,        status
,        title
,        manager_id
    from source
)
select * from renamed
