with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        channel
,        start_date
,        end_date
,        status
,        goal
    from source
)
select * from renamed
