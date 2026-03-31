with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        target_audience
,        channel
,        status
,        end_date
,        goal
    from source
)
select * from renamed
