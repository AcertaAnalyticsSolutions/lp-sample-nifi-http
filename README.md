# Apache Nifi and MS SQL database example

## Introduction
This repository demonstrates how to send data from an MS SQL Database to the Acerta LinePulse platform via an HTTP POST request using a **Data Integration Platform** called [Apache NiFi](https://nifi.apache.org/).

## Prerequisites
- Docker and Docker Compose should be installed

## Deployment steps

### Step 1. Creating secrets
* Copy the contents of [test.env](./test.env) to a file named `.env`
* Update the passwords in `.env`, if necessary.

### Step 2. Start the containers
To start the containers in detached mode, run the following command:
```
docker compose up -d
```

This will create and initialize the following Linux containers:
- Apache Nifi ver. 2.0.0-M4
- Microsoft SQL Server database 2022-CU13-ubuntu-22.04


## Testing the application
- Navigate to the Nifi UI page: http://127.0.0.1:8443 (This URL might vary based on setup)
- Log in using the credentials provided in the `docker-compose.yaml` and `.env` files: 
    * Username: `admin`
    * Password: Value of the `NIFI_ADMIN_PASSWORD` key in the `.env` file

- In the main page you should see two Process Groups:
    - Insert simulated data into MSSQL every 1sec
    - Ingest data from MSSQL into LinePulse every 10sec

- Right-click and press `Start` on each block and no errors should be present on the statistics bar. Right-click outside the blocks and press on the `Refresh` menu option to see updated status.

- There are 2 options to check if the data is being ingested properly:
    1. Directly in the database: You can connect to the database and you should see a record being inserted every second with the `ingestedAt` column empty. Then every 10 seconds this column will be populated with the actual time for all the empty records.
        * Use a MS SQL client such as SQL Server Management Studio (SSMS) or DBeaver to connect
        * Database username: `sa`
        * Database password: Take the value of the `MSSQL_SA_PASSWORD` key in the `.env` file 
    2. Using the Nifi UI: Click on the menu (top right side of the screen) and select `Data Provenance`. Then filter by component name: `Send Records to LinePulse`. Look for records with `Type` equals `FORK` and expand the details (by clicking on the ellipsis or the three-dot icon and click `View Details` option), and in the Attributes tab there is field called `invokehttp.status.code` that should have a value `201` if the request was successful.
        * Only the last 1000 records will be shown in the UI

## Troubleshooting
- Using the command: `docker ps` you should be able to verify if these two containers are running:
    - nifi
    - msql
- Check the container logs for errors using `docker logs {container_name}`
- Connect to the database on port `1433` with  the `sa` credentials from the `.env` file using MS SQL Management Studio or your preferred SQL client for further investigation if required.

## Terminating
Stop the running containers:
``` 
docker compose down -v
```