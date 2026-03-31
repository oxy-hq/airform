with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        title
,        last_name
,        salary
,        hire_date
    from source
)
select * from renamed
