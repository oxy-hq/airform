with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        manager_id
,        department_id
,        title
,        status
,        last_name
    from source
)
select * from renamed
