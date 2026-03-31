with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        budget
,        location
,        region
,        parent_id
,        department_name
,        created_at
,        head_count
    from source
)
select * from renamed
