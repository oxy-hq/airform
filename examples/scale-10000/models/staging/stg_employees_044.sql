with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        title
,        status
,        hire_date
,        salary
,        manager_id
    from source
)
select * from renamed
