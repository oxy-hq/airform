with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        status
,        campaign_name
,        start_date
,        target_audience
,        goal
,        budget
,        channel
    from source
)
select * from renamed
