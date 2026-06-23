CREATE TABLE agents (
    agent_id        INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    license_number  VARCHAR(30) NOT NULL UNIQUE,
    email           VARCHAR(120) NOT NULL UNIQUE,
    hire_date       DATE NOT NULL
) ENGINE=InnoDB COMMENT='Real estate agents who facilitate transactions.';
