with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        status
,        first_name
,        last_name
,        manager_id
    from source
)
select * from renamed
