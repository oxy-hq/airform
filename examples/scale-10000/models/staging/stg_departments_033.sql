with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        budget
,        status
,        location
,        department_name
    from source
)
select * from renamed
