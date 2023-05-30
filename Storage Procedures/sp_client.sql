-- Insert the client record into the clients table
CREATE PROCEDURE sp_insert_vendor(
  IN p_name VARCHAR(100),
  IN p_last_name VARCHAR(100),
  IN p_company_id BIGINT,
  IN p_cell_number VARCHAR(20),
  IN p_email VARCHAR(255),
  IN p_street VARCHAR(255),
  IN p_city VARCHAR(100),
  IN p_state VARCHAR(100),
  IN p_zip_code VARCHAR(20),
  IN p_country VARCHAR(10)
)
BEGIN
  DECLARE last_id BIGINT DEFAULT 0;
  START TRANSACTION;
    INSERT
	INTO
	vendors(name,
	last_name,
	company_id,
	cell_number,
	email)
VALUES (p_name,
p_last_name,
p_company_id,
p_cell_number,
p_email);
--    save for vendor_address insert
    SET last_id = LAST_INSERT_ID();

    INSERT INTO addresses(street, city, state, zip_code, country)
    VALUES (p_street, p_city, p_state, p_zip_code, p_country);
   
    INSERT INTO vendor_addresses (address_id, vendor_id)
    VALUES (LAST_INSERT_ID(), last_id);
  COMMIT;
END;

-- Get all clients
CREATE PROCEDURE sp_get_clients()
BEGIN
  -- select that fields we will work with
  SELECT client_id, name, last_name, email, cell_number, life_stage FROM clients;
END;

-- get addresses of client by client id
CREATE PROCEDURE sp_get_client_addresses(
  IN p_client_id BIGINT
)
BEGIN
  SELECT 
	  a.address_id, a.street, a.city, a.state, a.zip_code 
  FROM addresses AS a 
  INNER JOIN client_addresses AS ca ON a.address_id = ca.address_id
  WHERE ca.client_id = p_client_id
  ORDER BY a.created_at DESC;
END;

-- get client by client id
CREATE PROCEDURE sp_get_client_by_id (
  IN p_client_id BIGINT
)
BEGIN
  SELECT c.client_id, c.name, c.last_name, c.email, c.cell_number, c.life_stage
  FROM clients AS c
  WHERE c.client_id = p_client_id;
END;

-- Delete address
CREATE PROCEDURE sp_delete_address(
  IN p_client_id BIGINT,
  IN p_address_id BIGINT
)
BEGIN
  START TRANSACTION;
  DELETE FROM client_addresses 
  WHERE client_id = p_client_id AND address_id = p_address_id;

  DELETE FROM addresses 
  WHERE address_id = p_address_id;
  COMMIT;
END;

-- update client
CREATE PROCEDURE sp_update_client (
  IN p_client_id BIGINT,
  IN p_name VARCHAR(100),
  IN p_last_name VARCHAR(100),
  IN p_email VARCHAR(255),
  IN p_cell_number VARCHAR(20),
  IN p_life_stage ENUM('customer', 'lead', 'opportunity')
)
BEGIN
  START TRANSACTION;
    UPDATE clients
    SET name = p_name,
        last_name = p_last_name,
        email = p_email,
        cell_number = p_cell_number,
        life_stage = p_life_stage
    WHERE client_id = p_client_id;
  COMMIT;
END;

-- If you are looking for the update address for client checkout the sp_address file


