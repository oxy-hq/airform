with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        category
,        reviewer_id
,        created_at
,        account_id
,        risk_level
,        reviewed_at
,        notes
    from source
)
select * from renamed
