with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        status
,        record_type
,        reviewed_at
,        reviewer_id
,        risk_level
,        notes
    from source
)
select * from renamed
