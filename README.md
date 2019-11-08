# Smart Noter: A Doccano-based Annotator

## Welcome to Smart Noter.

An easy-to-use solution to your visualization needs. Firstly, implemented along with the Vue.js framework, you can define your components, services, routes, and storages. Lastly, you can also use our own. We offer both solutions and all the essential tools that you need in order to construct a front-end. Please, follow along the next sections in order to learn more about this excellent tool.

Smart Front is compatible with the latest: **Vue.js**.

---

## Package guidelines

1. The very first information you need is in the very **next** section.
2. **Installing** is also easy if you wish to read the code and bump yourself into, follow along.
3. Note that there might be some **additional** steps in order to use our solutions.
4. If there is a problem, please do not **hesitate**, call us.

---

## Installation

We believe that everything has to be easy. Not tricky or daunting, Smart Noter will be the one-to-go package that you will need, from the very first installation to the daily-tasks implementing needs.

### Cloning

First of all, clone the repository:

```bash
git clone https://github.com/recogna-lab/smart_noter.git
cd smart_noter
```

_Note for Windows developers: Be sure to configure git to correctly handle line endings or you may encounter `status code 127` errors while running the services in future steps. Running with the git config options below will ensure your git directory correctly handles line endings._

```bash
git clone https://github.com/recogna-lab/smart_noter.git --config core.autocrlf=input
```

### Starting

In order to install the Smart Noter, use the following command:

```bash
docker-compose pull
```

### Usage

We can use docker-compose to set up the webpack server, django server, database, etc. all in one command:

```bash
docker-compose up
```

_Note the superuser account credentials located in the `docker-compose.yaml` file:_
```yml
ADMIN_USERNAME: "admin"
ADMIN_PASSWORD: "password"
```

Open a Web browser and go to <http://127.0.0.1:8000/login/>. You should see the login screen.

---

## Environment configuration

Note that sometimes, there is a need for additional implementation. If needed, from here you will be the one to know all of its details.

### Ubuntu

No specific additional commands needed.

### Windows

No specific additional commands needed.

### MacOS

No specific additional commands needed.

---

## Support

We know that we do our best, but it is inevitable to acknowledge that we make mistakes. If you ever need to report a bug, report a problem, talk to us, please do so! We will be available at our bests at this repository or gth.rosa@uol.com.br.

---