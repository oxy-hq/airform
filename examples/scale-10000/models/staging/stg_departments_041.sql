with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        parent_id
,        status
,        budget
,        region
,        department_name
,        location
    from source
)
select * from renamed
