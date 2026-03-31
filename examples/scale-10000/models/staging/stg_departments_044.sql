with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        status
,        department_name
,        budget
,        location
    from source
)
select * from renamed
