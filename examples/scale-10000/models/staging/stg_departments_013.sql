with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        parent_id
,        budget
,        region
    from source
)
select * from renamed
