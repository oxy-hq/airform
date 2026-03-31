with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        status
,        budget
,        target_audience
,        channel
,        campaign_name
,        start_date
    from source
)
select * from renamed
