with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        account_id
,        category
,        notes
,        risk_level
,        reviewed_at
,        reviewer_id
    from source
)
select * from renamed
