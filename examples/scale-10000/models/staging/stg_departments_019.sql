with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        location
,        department_name
,        cost_center
    from source
)
select * from renamed
