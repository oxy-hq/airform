with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),

renamed as (
    select
        id as compliance_record_id
,        reviewed_at
,        notes
,        record_type
,        created_at
,        status
,        reviewer_id
    from source
)

select * from renamed
