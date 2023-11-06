-- Creation of sp create service without service must include validation
DROP PROCEDURE IF EXISTS sp_create_service_schedule;
CREATE PROCEDURE sp_create_service_schedule(
    IN p_client_id BIGINT, 
    IN p_address_id BIGINT, 
    IN p_start_time TIME, 
    IN p_end_time TIME,
    IN p_to_do_date DATE,
    IN p_services JSON, 
    IN p_materials JSON, 
    IN p_employees JSON
)
BEGIN 
    DECLARE currentIndex INT DEFAULT 0;
    DECLARE totalElements INT;
    DECLARE currentElement JSON;
    DECLARE last_id BIGINT DEFAULT 0;
    DECLARE p_service_id BIGINT;
    DECLARE p_quantity INT;
    DECLARE p_material_id BIGINT;
    DECLARE p_subtotal DECIMAL(10,2);
    DECLARE p_employee_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING, NOT FOUND
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET
        MESSAGE_TEXT = 'An error occurred during service schedule creation.';
    END;
    
    START TRANSACTION;
    
    -- Insert into service schedule
    INSERT INTO service_schedule (
        client_id,
        address_id,
        start_time,
        end_time,
        to_do_date,
        type,
        status
    )
    VALUES (
        p_client_id, 
        p_address_id, 
        p_start_time, 
        p_end_time, 
        p_to_do_date,
        'single',
        'pending'
    );
    
    -- Get the last inserted id
    SET last_id = LAST_INSERT_ID();
    
    -- Insert services
    SET totalElements = JSON_LENGTH(p_services);
    -- services can be left as a blank array if they want to add services later
    IF totalElements > 0 THEN 
        WHILE currentIndex < totalElements DO
            SET currentElement = JSON_EXTRACT(p_services, CONCAT('$[', currentIndex, ']'));
            
            -- Process current JSON
            SET p_service_id = JSON_EXTRACT(currentElement, '$.service_id');
            SET p_quantity = JSON_EXTRACT(currentElement, '$.quantity');
            
            -- Insert statement
            INSERT INTO scheduled_service_services (
                service_schedule_id, 
                service_id, 
                quantity
            ) 
            VALUES (
                last_id,
                p_service_id,
                p_quantity
            );
            
            SET currentIndex = currentIndex + 1;
        END WHILE;
    ELSE 
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET
        MESSAGE_TEXT = 'No services provided';
    END IF;
    
    -- Insert materials
    SET currentIndex = 0;
    SET totalElements = JSON_LENGTH(p_materials);
    IF totalElements > 0 THEN 
        WHILE currentIndex < totalElements DO
            SET currentElement = JSON_EXTRACT(p_materials, CONCAT('$[', currentIndex, ']'));
            
            -- Process current JSON
            SET p_material_id = JSON_EXTRACT(currentElement, '$.material_id');
            SET p_quantity = JSON_EXTRACT(currentElement, '$.quantity');
            SET p_subtotal = JSON_EXTRACT(currentElement, '$.subtotal');
            
            -- Insert statement
            INSERT INTO scheduled_service_materials (
                service_schedule_id,
                material_id,
                quantity,
                subtotal
            ) 
            VALUES (
                last_id, 
                p_material_id,
                p_quantity,
                p_subtotal
            );
            
            SET currentIndex = currentIndex + 1;
        END WHILE;
    END IF;
    
    -- Insert employees
    SET currentIndex = 0;
    SET totalElements = JSON_LENGTH(p_employees);
    IF totalElements > 0 THEN 
        WHILE currentIndex < totalElements DO
            SET currentElement = JSON_EXTRACT(p_employees, CONCAT('$[', currentIndex, ']'));
            
            -- Process current JSON
            SET p_employee_id = JSON_EXTRACT(currentElement, '$.employee_id');
            
            -- Insert statement
            INSERT INTO employees_at_service_scheduled (
                service_schedule_id, 
                employee_id
            ) 
            VALUES (
                last_id,
                p_employee_id
            );
            
            SET currentIndex = currentIndex + 1;
        END WHILE;
    END IF;
    COMMIT;
END;


CALL sp_create_service_schedule(
    6, -- p_client_id
    7, -- p_address_id
    '12:30:00', -- p_start_time (added ':00' for seconds with leading zeros)
    '02:30:00', -- p_end_time (added ':00' for seconds with leading zeros)
    '2023-06-20', -- p_to_do_date
    '[{"service_id": 3, "quantity": 2}]', -- p_services
    '[{"material_id": 1, "quantity": 4, "subtotal": 50.00}, {"material_id": 2, "quantity": 2, "subtotal": 30.00}]', -- p_materials
    '[{"employee_id": 11}, {"employee_id": 16}]' -- p_employees
);


###################################################################################################################################