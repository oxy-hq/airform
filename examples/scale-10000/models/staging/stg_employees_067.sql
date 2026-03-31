with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        status
,        last_name
,        hire_date
    from source
)
select * from renamed
