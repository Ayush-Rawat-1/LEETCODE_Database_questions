WITH RECURSIVE 
-- Step 1: Traverse top-down from the CEO to find each employee's organizational level
Org_Levels AS (
    -- Anchor Member: Start with the CEO (who has no manager) at Level 1
    SELECT
        employee_id,
        employee_name,
        1 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL
    
    -- Recursive Member: Move down layer-by-layer to find direct reports
    SELECT
        e.employee_id,
        e.employee_name,
        ol.level + 1
    FROM Employees e
    JOIN Org_Levels ol ON e.manager_id = ol.employee_id
),

-- Step 2: Build a map linking every manager to ALL of their direct and indirect reports
Subordinate_Mapping AS (
    -- Anchor Member: Link every employee to themselves to establish the base of their tree
    SELECT
        employee_id AS manager_id,
        employee_id AS report_id,
        salary
    FROM Employees

    UNION ALL

    -- Recursive Member: Traverse down the tree to link a manager to their reports' reports
    SELECT
        sm.manager_id,
        e.employee_id AS report_id,
        e.salary
    FROM Employees e
    JOIN Subordinate_Mapping sm ON sm.report_id = e.manager_id
),

-- Step 3: Aggregate the metrics for each manager using the subordinate map
Manager_Rollups AS (
    SELECT
        manager_id,
        -- Subtract 1 because employees shouldn't count themselves as part of their own team size
        COUNT(report_id) - 1 AS team_size,
        -- The SUM automatically includes the manager's own salary because of the anchor mapping step
        SUM(salary) AS budget
    FROM Subordinate_Mapping
    GROUP BY manager_id
)

-- Step 4: Combine organizational levels with rolled-up metrics and format final output
SELECT
    ol.employee_id,
    ol.employee_name,
    ol.level,
    mr.team_size,
    mr.budget
FROM Org_Levels ol
JOIN Manager_Rollups mr ON ol.employee_id = mr.manager_id
ORDER BY 
    level ASC, 
    budget DESC, 
    employee_name ASC;
