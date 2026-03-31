with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        record_type
,        status
,        category
,        reviewed_at
,        risk_level
,        created_at
,        account_id
    from source
)
select * from renamed
