with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        budget
,        location
,        head_count
,        department_name
,        status
,        region
,        parent_id
    from source
)
select * from renamed
