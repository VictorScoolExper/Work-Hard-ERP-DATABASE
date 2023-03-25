CREATE TABLE users(
  user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  last_name VARCHAR(200) NOT NULL,
  cell_number VARCHAR(20),
  role VARCHAR(20),
  age INT,
  active ENUM("true", "false"),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE employees (
    employee_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL,
    created_by_user BIGINT NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    driver_license VARCHAR(250) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE DEFAULT NULL,
    wage_per_hour DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (created_by_user) REFERENCES users(user_id)
);
