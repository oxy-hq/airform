with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        start_date
,        status
,        campaign_name
,        budget
,        goal
    from source
)
select * from renamed
