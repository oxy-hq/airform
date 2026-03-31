with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        salary
,        last_name
,        title
,        status
,        hire_date
    from source
)
select * from renamed
