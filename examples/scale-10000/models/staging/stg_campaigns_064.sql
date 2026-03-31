with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        start_date
,        end_date
,        channel
,        campaign_name
,        goal
,        status
    from source
)
select * from renamed
