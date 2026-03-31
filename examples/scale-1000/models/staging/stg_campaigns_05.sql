with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),

renamed as (
    select
        id as campaign_id
,        target_audience
,        budget
,        start_date
    from source
)

select * from renamed
