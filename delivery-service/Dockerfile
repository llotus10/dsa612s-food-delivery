FROM ballerina/ballerina:2201.12.0
WORKDIR /home/ballerina
COPY . .
RUN bal build
EXPOSE 8091
CMD ["bal", "run"]