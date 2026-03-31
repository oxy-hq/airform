with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        status
,        region
,        budget
,        department_name
    from source
)
select * from renamed
