with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        region
,        location
,        department_name
,        budget
    from source
)
select * from renamed
