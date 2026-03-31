with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        notes
,        created_at
,        account_id
,        record_type
,        reviewed_at
,        reviewer_id
    from source
)
select * from renamed
