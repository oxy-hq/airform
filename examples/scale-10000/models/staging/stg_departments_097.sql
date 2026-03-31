with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        status
,        department_name
,        region
,        parent_id
    from source
)
select * from renamed
