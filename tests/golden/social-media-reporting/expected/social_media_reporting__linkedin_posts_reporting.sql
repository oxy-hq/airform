with report as (

    select *
    from linkedin_pages__posts

), fields as (

    select        
        cast(organization_id as TEXT) as page_id,
        cast(organization_name as TEXT) as page_name,
        cast(post_id as TEXT) as post_id,
        created_timestamp,
        cast(post_url as TEXT) as post_url,
        source_relation,
        'linkedin' as platform,
        cast(coalesce(post_title, commentary) as TEXT) as post_message,
        coalesce(sum(click_count),0) as clicks,
        coalesce(sum(comment_count),0) as comments,
        coalesce(sum(impression_count),0) as impressions,
        coalesce(sum(like_count),0) as likes,
        coalesce(sum(share_count),0) as shares
    from report
    group by 1,2,3,4,5,6,7,8

)

select *
from fields
