with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        last_name
,        title
,        department_id
,        salary
,        manager_id
    from source
)
select * from renamed
