
FROM alpine

RUN apk update && apk add git --no-cache git nodejs npm
RUN git clone https://github.com/hassenkhalifa/DevOps_Projects.git

WORKDIR /tmp/devops_projects/Dockerized_Service/NodeJsApp

RUN npm i

CMD ["node","app.js"]
