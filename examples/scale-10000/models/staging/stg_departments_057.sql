with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        created_at
,        location
,        budget
,        status
,        department_name
,        region
    from source
)
select * from renamed
