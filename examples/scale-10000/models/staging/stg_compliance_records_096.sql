with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        record_type
,        reviewer_id
,        category
,        created_at
,        risk_level
,        notes
    from source
)
select * from renamed
