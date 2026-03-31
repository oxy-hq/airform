with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        budget
,        end_date
,        channel
,        start_date
,        target_audience
,        goal
,        campaign_name
    from source
)
select * from renamed
