with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        reviewer_id
,        account_id
,        record_type
,        status
,        created_at
,        notes
,        reviewed_at
    from source
)
select * from renamed
