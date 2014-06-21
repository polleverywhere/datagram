# Datagram

Datagram is Gist for SQL. Quickly recall saved queries and transform results using JavaScript.

![Alt text](https://s3.amazonaws.com/uploads.hipchat.com/62638/564879/GGYbQ5Ioucq9i4H/upload.png "Datagram screenshot")

## About

Datagram runs as a [Docker][docker] container. It requires a host running [Docker][docker] (or boot2docker on Mac), a query storage database (a SQLite file on the Datagram container or other database), and read-only access of your database to run the queries against.

## Usage

Datagram is build as a [Docker][docker] container and can run on any host supporting [Docker][docker]. In the following example, we will install boot2docker to run this on a Mac host.

### Prerequisites

* [Docker][docker] installed on a host (see installation instructions for your specific host):
  * Mac - https://docs.docker.com/installation/mac/
  * Ubuntu - https://docs.docker.com/installation/ubuntulinux/
  * Others - https://docs.docker.com/installation/
* Access to a database to report against
* Creation of a query database to store saved queries

### Configuration

Datagram is configured by two environment variables:

* `QUERY_DATABASE_URL` - The database that Datagram stores user written queries.
* `REPORTING_DATABASE_URL` - The database that Datagram runs queries against. *Make sure this is being accessed via a read-only database account*

These can be passed on the command line while running Datagram or as an environment file (such as `datagram.env`). An example `datagram.env` may look like:

    QUERY_DATABASE_URL=sqlite:///datagram/storage/query_database.db
    REPORTING_DATABASE_URL=mysql2://readonly:mypassword@database.mydomain.com/database_name

### Running

In this example, we will run two containers. One will be the storage for the query database and the other will be Datagram itself.

  # Run the data container
  docker run -v /datagram/storage -d --name datagram-data ubuntu /bin/true

  # Create the SQLite file that matches the `QUERY_DATABASE_URL` location
  docker run --env-file $(pwd)/datagram.env --volumes-from datagram-data --rm polleverywhere/datagram touch /datagram/storage/query_database.db

  # Run the Datagram SQL migrations
  docker run --env-file $(pwd)/datagram.env --volumes-from datagram-data --rm polleverywhere/datagram datagram migrate

  # Run Datagram on default port 5000
  docker run --env-file $(pwd)/datagram.env --volumes-from datagram-data -p 5000:5000 -d --name datagram polleverywhere/datagram

You should now be able to visit datagram at your Docker host IP via port 5000. You can get the IP address of your boot2docker VM using `boot2docker ip`.

## Development

When developing on Datagram locally, you can run the application from Foreman without needing to build the application repeatedly in Docker.

### Configuration

Your local development environment should be configured using a `.env` file. You can copy the `.env.sample` file to `.env` and edit it according to your environment.

### Running

Run the application with Foreman:

    bundle exec foreman start

Now visit Datagram at http://localhost:5000 and you should be ready to write some queries!

## Security

Datagram makes no assumptions about security, so make sure you do the following in a production environment:

1. Make sure the `REPORTING_DATABASE_URL` database is using an account with read-only permissions. You don't want users accidentally deleting data! Your database administrator should be able to set this.
2. Its highly recommended that you only make datagram accessible via HTTPS. Transfering your database content over the wire in the clear is not a good idea. We recommend running Datagram behind a load balancer or proxy that supports SSL.
3. Datagram provides no authentication or authorizaiton services. The easiest way to implement a username and password is via HTTP Basic authorization through either a rack middleware (building a new Docker image based on this one) or in the proxy configuration over HTTPS.

You've been warned!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[docker]: http://www.docker.com/
