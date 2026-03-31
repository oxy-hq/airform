with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        start_date
,        spend
,        goal
,        target_audience
,        status
,        budget
,        campaign_name
    from source
)
select * from renamed
