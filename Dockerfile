# Start with a minimal Docker image
FROM openjdk:10-slim

# Copy the pipeline scripts from the ouside of the container into the container
COPY Pipeline.mk /

# Use root in the container to make the script executable
USER root

# Make the script executable, create Regovar directories and download VarScan
RUN chmod +x /Pipeline.mk && \
	mkdir -p /regovar/{inputs,outputs,logs,databases} && \
	curl -L https://sourceforge.net/projects/varscan/files/VarScan.v2.3.9.jar/download -o VarScan.v2.3.9.jar

# Run the pipeline
CMD ["make -f Pipeline.mk"]
