with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        status
,        end_date
,        start_date
,        campaign_name
,        channel
    from source
)
select * from renamed
