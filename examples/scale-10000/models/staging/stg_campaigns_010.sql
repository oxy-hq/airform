with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        budget
,        start_date
,        campaign_name
,        goal
,        end_date
,        target_audience
    from source
)
select * from renamed
