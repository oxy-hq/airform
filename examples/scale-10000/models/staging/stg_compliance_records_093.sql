with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        record_type
,        category
,        status
,        notes
,        reviewer_id
    from source
)
select * from renamed
