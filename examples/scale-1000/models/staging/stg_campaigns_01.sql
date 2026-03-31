with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),

renamed as (
    select
        id as campaign_id
,        target_audience
,        goal
,        budget
,        status
    from source
)

select * from renamed
