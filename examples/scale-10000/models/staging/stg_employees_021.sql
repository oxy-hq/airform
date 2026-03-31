with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        status
,        salary
,        department_id
,        first_name
    from source
)
select * from renamed
