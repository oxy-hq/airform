with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        salary
,        department_id
,        status
    from source
)
select * from renamed
