# Apache Nifi and MS SQL database example

## Introduction
The intent of this project is to demonstrate how to send data from a MS SQL Database to Acerta LinePulse platform via HTTP POST request using a **Data Integration Platform** called [Apache Nifi](https://nifi.apache.org/)

## Requirements
- Docker and Docker Compose should be installed

## Deployment steps
The following steps create and initialize these two Linux containers: 
- Apache Nifi ver. 2.0.0-M4
- Microsoft SQl Server database 2022-CU13-ubuntu-22.04

### Creating secrets
Copy or rename [test.env](./test.env) to a file named: `.env`. Update the passwords according to your requirements.

### Start the containers
```
docker compose up -d
```

## Testing the application
- Navigate to the Nifi UI page: http://127.0.0.1:8443
- Log in using the credentials provided in the `docker-compose.yaml` and `.env` files: `admin` and `My_NiFi_Password123` if it hasn't been changed.

- In the main page you should see two Process Groups:
    - Insert simulated data into MSSQL every 1sec
    - Ingest data from MSSQL into LinePulse every 10sec

- Right click and press `Start` on each block and no errors should be present on the statiscs bar
- To check if the data is being ingested properly you can connect to the database and you should see a record being inserted every second with the `ingestedAt` column empty. Then every 10 seconds this column will be populated with the actuall time for all the empty records.
- To verify in the Nifi UI click on the menu (top right side of the screen) and select `Data Provenance`. Then filter by component name: `Send Records to LinePulse`. Look for the `FORK` type and expand the details, in the Attributes tab there is field called `invokehttp.status.code` that should have a value 201 if the request was successful.

## Troubleshooting
- Using the command: `docker ps` you should be able to verify if these two containers are running:
    - nifi
    - msql
- Check the container logs for errors using `docker logs {container_name}`
- Connect to the database on port `1433` with  the `sa` credentials from the `.env` file using MS SQL Management Studio or your preferred SQL client for further investigation if required.

## Terminating
Stop the containers running:
``` 
docker compose down -v
```