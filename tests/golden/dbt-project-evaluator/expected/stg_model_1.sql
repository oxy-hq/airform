-- this needs to be valid SQL for the fake test to run
-- depends on: "dbt_project_evaluator_integration_tests_2"."real_schema"."table_1"
select 1 as id 
union all 
select 2 as id
