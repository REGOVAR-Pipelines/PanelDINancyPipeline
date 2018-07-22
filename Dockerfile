# Start with a minimal Docker image
FROM openjdk:latest

# Copy the pipeline scripts from the ouside of the container into the container
COPY Pipeline.mk /

# Use root in the container to make the script executable
USER root
RUN chmod +x /Pipeline.mk
RUN mkdir -p /regovar/{inputs,outputs,logs,databases}

# Run the pipeline
CMD ["make -f Pipeline.mk"]
