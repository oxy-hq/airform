with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        reviewer_id
,        created_at
,        category
,        account_id
,        record_type
,        risk_level
    from source
)
select * from renamed
