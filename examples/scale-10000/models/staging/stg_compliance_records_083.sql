with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        reviewer_id
,        account_id
,        record_type
,        risk_level
,        notes
,        reviewed_at
,        created_at
    from source
)
select * from renamed
