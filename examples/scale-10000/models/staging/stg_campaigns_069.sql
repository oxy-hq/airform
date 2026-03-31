with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        campaign_name
,        target_audience
,        budget
,        end_date
,        goal
,        start_date
,        status
    from source
)
select * from renamed
