with __dbt__cte__stg_model_1 as (
-- this needs to be valid SQL for the fake test to run
-- depends on: "dbt_project_evaluator_integration_tests_2"."real_schema"."table_1"
select 1 as id 
union all 
select 2 as id
) -- depends on: __dbt__cte__stg_model_1
-- depends on: "dbt_project_evaluator_integration_tests_2"."real_schema"."table_2"

select 1 as id
